# frozen_string_literal: true

module JournalEntryData
  class Generator
    CATEGORY_EXPENSE_SUMMARY = 23
    PATTERN_GROUP_STORE = 4
    PATTERN_GROUP_LABOR = 9

    # JournalEntryDataListApplication::Create()
    def self.call(form)
      new(form).call
    end

    def initialize(form)
      @form = form
    end

    # JournalEntryDataListApplication::Create()
    def call
      missing_capture_numbers = capture_history_numbers_without_journal_entries
      return ServiceResult.new(success: true) if missing_capture_numbers.empty?

      if form.fund_transfer_date.blank?
        form.errors.add(:fund_transfer_date, "資金移動日を入力してください。")
        return ServiceResult.new(
          success: false,
          message: "資金移動日を入力してください。",
          payload: { form: form }
        )
      end

      history_ids = nil

      ActiveRecord::Base.transaction do
        history_ids = record_histories(missing_capture_numbers)
        create_journal_entry_data(history_ids)
      end

      ServiceResult.new(success: true, payload: { history_ids: history_ids })
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("JournalEntryData::Generator validation failed: #{e.message}")
      form.errors.add(:base, "仕訳データの作成に失敗しました。")
      ServiceResult.new(success: false, message: "仕訳データの作成に失敗しました。 #{e.message}", payload: { form: form })
    rescue StandardError => e
      Rails.logger.error(
        "JournalEntryData::Generator failed: #{e.class} #{e.message}\n#{e.backtrace.join("\n")}"
      )
      form.errors.add(:base, "仕訳データの作成に失敗しました。")
      ServiceResult.new(success: false, message: "仕訳データの作成に失敗しました。 #{e.message}", payload: { form: form })
    end

    private

    attr_reader :form

    # JournalEntryDataListApplication::GetNoJournalEntryHistory()
    def payment_month
      form.payment_month_date
    end

    # JournalEntryDataListApplication::GetNoJournalEntryHistory()
    def payment_month_range
      return nil unless payment_month

      payment_month.beginning_of_month..payment_month.end_of_month
    end

    # JournalEntryDataListApplication::GetNoJournalEntryHistory()
    def capture_history_numbers_without_journal_entries
      scope = TrnCaptureHistory.all
      scope = scope.where(PAYMENT_MONTH: payment_month_range) if payment_month_range
      scope = scope.where(CAPTURE_CATEGORY_NO: form.supplier) unless form.supplier_all?

      scope
        .left_outer_joins(:journal_entry_histories)
        .where(TRN_JOURNAL_ENTRY_HISTORY: { JOURNAL_ENTRY_HISTORY_NO: nil })
        .pluck(:CAPTURE_HISTORY_NO)
    end

    # JournalEntryDataListApplication::RecordHistory()
    def record_histories(capture_history_numbers)
      capture_history_numbers.map do |history_no|
        capture_history = TrnCaptureHistory.find(history_no)

        history = TrnJournalEntryHistory.create!(
          capture_history_no: capture_history.capture_history_no,
          accrual_month: capture_history.accrual_month,
          payment_month: capture_history.payment_month,
          capture_category_no: capture_history.capture_category_no,
          execute_flg: false,
          create_user_id: current_user_id,
          create_date: Time.zone.now
        )

        history.journal_entry_history_no
      end
    end

    # JournalEntryDataListApplication::Create()
    def create_journal_entry_data(history_ids)
      history_ids.each do |history_id|
        history = TrnJournalEntryHistory.find_by(journal_entry_history_no: history_id)
        capture_category = capture_category(history.capture_category_no)

        patterns = JournalEntryPattern
                   .where(JOURNAL_ENTRY_PATTERN_GROUP_NO: capture_category.journal_entry_pattern_group_no)
                   .order(:ROW_NO, :JOURNAL_ENTRY_PATTERN_NO)

        capture_rows = TrnCaptureData
                       .where(CAPTURE_HISTORY_NO: history.capture_history_no)
                       .order(:DEPARTMENT_NO, :ROW_NO)

        grouping_rows = []
        capture_rows.each do |row|
          next if skip_expense_summary_row?(capture_category.capture_category_no, row)

          patterns.each do |pattern|
            next if skip_store_pattern_row?(pattern, row.company_no)

            debit_account = account_for(pattern["DEBIT_ACCOUNT_NO"], capture_category.capture_category_no, "debit")
            credit_account = account_for(pattern["CREDIT_ACCOUNT_NO"], capture_category.capture_category_no, "credit")

            debit_amount = amount_for(pattern, row, "debit", debit_account)
            credit_amount = amount_for(pattern, row, "credit", credit_account)

            entry_hash = build_entry_hash(
              history: history,
              pattern: pattern,
              capture_category: capture_category,
              capture_row: row,
              debit_account: debit_account,
              credit_account: credit_account,
              debit_amount: debit_amount,
              credit_amount: credit_amount
            )

            if pattern["JOURNAL_ENTRY_PATTERN_GROUP_NO"] == PATTERN_GROUP_STORE && [7, 8].include?(pattern["ROW_NO"])
              grouping_rows << entry_hash
            else
              create_entry(entry_hash)
            end
          end
        end

        create_grouped_store_entries(grouping_rows, history)
      end
    end

    # JournalEntryDataListApplication::Create() - grouped store aggregation
    def create_grouped_store_entries(grouping_rows, history)
      return if grouping_rows.blank?

      grouping_rows
        .group_by do |row|
          [
            row[:row_no],
            row[:date],
            row[:debit_department_no],
            row[:debit_account_no],
            row[:debit_sub_account_no],
            row[:debit_supplier_id],
            row[:credit_department_no],
            row[:credit_account_no],
            row[:credit_sub_account_no],
            row[:credit_supplier_id],
            row[:abstract]
          ]
        end
        .each do |key, rows|
          debit_sum = grouped_amount(rows, :debit_amount)
          credit_sum = grouped_amount(rows, :credit_amount)

          create_entry(
            journal_entry_history_no: history.journal_entry_history_no,
            row_no: key[0],
            excel_row_no: 0,
            date: key[1],
            company_no: 1,  # ウィーズ
            department_no: 201,
            debit_department_no: key[2],
            debit_account_no: key[3],
            debit_sub_account_no: key[4],
            debit_supplier_id: key[5],
            debit_amount: sum_amount(debit_sum),
            credit_department_no: key[6],
            credit_account_no: key[7],
            credit_sub_account_no: key[8],
            credit_supplier_id: key[9],
            credit_amount: sum_amount(credit_sum),
            abstract: key[10],
            debit_tax_class_no: nil,
            debit_tax_rate_no: nil,
            credit_tax_class_no: nil,
            credit_tax_rate_no: nil
          )
        end
    end

    # JournalEntryDataListApplication::Create()
    def build_entry_hash(history:, pattern:, capture_category:, capture_row:, debit_account:, credit_account:, debit_amount:, credit_amount:)
      {
        journal_entry_history_no: history.journal_entry_history_no,
        row_no: pattern["ROW_NO"],
        excel_row_no: capture_row.row_no,
        date: date_for(pattern["DATE_PATTERN_NO"], history.accrual_month, history.payment_month, form.fund_transfer_date),
        company_no: company_for(pattern["COMPANY_NO"], capture_row.company_no, capture_category.capture_category_no),
        department_no: capture_row.department_no,
        debit_department_no: department_for(pattern["DEBIT_DEPARTMENT_NO"], capture_row.department_no, capture_row.company_no, capture_category.capture_category_no, "debit"),
        debit_account_no: debit_account,
        debit_sub_account_no: sub_account_for(pattern["DEBIT_SUB_ACCOUNT_NO"], capture_category.capture_category_no, "debit"),
        debit_supplier_id: supplier_for(pattern.debit_supplier_id, capture_row.company_no, capture_row.supplier_id, capture_category.capture_category_no),
        debit_amount: debit_amount,
        debit_tax_class_no: tax_class_for(pattern["DEBIT_TAX_CLASS"], capture_category.capture_category_no),
        debit_tax_rate_no: tax_rate_for(pattern["DEBIT_TAX_RATE"], capture_category.capture_category_no),
        credit_department_no: department_for(pattern["CREDIT_DEPARTMENT_NO"], capture_row.department_no, capture_row.company_no, capture_category.capture_category_no, "credit"),
        credit_account_no: credit_account,
        credit_sub_account_no: sub_account_for(pattern["CREDIT_SUB_ACCOUNT_NO"], capture_category.capture_category_no, "credit"),
        credit_supplier_id: supplier_for(pattern.credit_supplier_id, capture_row.company_no, capture_row.supplier_id, capture_category.capture_category_no),
        credit_amount: credit_amount,
        credit_tax_class_no: tax_class_for(pattern["CREDIT_TAX_CLASS"], capture_category.capture_category_no),
        credit_tax_rate_no: tax_rate_for(pattern["CREDIT_TAX_RATE"], capture_category.capture_category_no),
        abstract: abstract_for(
          pattern["ABSTRACT"].to_s,
          history.accrual_month,
          history.payment_month,
          capture_row.department_no,
          capture_row.company_no,
          capture_category.capture_category_no
        )
      }
    end

    # JournalEntryDataListApplication::Create()
    def create_entry(attributes)
      TrnJournalEntryData.create!(
        journal_entry_history_no: attributes[:journal_entry_history_no],
        row_no: attributes[:row_no],
        excel_row_no: attributes[:excel_row_no],
        date: attributes[:date],
        company_no: attributes[:company_no],
        department_no: attributes[:department_no],
        debit_department_no: attributes[:debit_department_no],
        debit_account_no: attributes[:debit_account_no],
        debit_sub_account_no: attributes[:debit_sub_account_no],
        debit_supplier_id: attributes[:debit_supplier_id],
        debit_amount: attributes[:debit_amount],
        debit_tax_class_no: attributes[:debit_tax_class_no],
        debit_tax_rate_no: attributes[:debit_tax_rate_no],
        credit_department_no: attributes[:credit_department_no],
        credit_account_no: attributes[:credit_account_no],
        credit_sub_account_no: attributes[:credit_sub_account_no],
        credit_supplier_id: attributes[:credit_supplier_id],
        credit_amount: attributes[:credit_amount],
        credit_tax_class_no: attributes[:credit_tax_class_no],
        credit_tax_rate_no: attributes[:credit_tax_rate_no],
        abstract: attributes[:abstract],
        create_user_id: current_user_id,
        create_date: Time.zone.now
      )
    end

    # JournalEntryDataListApplication::Create() - expense summary skip
    def skip_expense_summary_row?(capture_category_no, capture_row)
      return false unless capture_category_no == CATEGORY_EXPENSE_SUMMARY

      account_no = capture_row.account_no
      row_number = capture_row.row_no

      # 832: 給与手当
      # 836: 法定福利費
      # 866: 旅費交通費
      # 854: 福利厚生費
      skip_accounts = [836, 866, 854]
      return false unless skip_accounts.include?(account_no)

      data_in_row = TrnCaptureData.where(
        CAPTURE_HISTORY_NO: capture_row.capture_history_no,
        ROW_NO: row_number
      )

      return true if data_in_row.where(ACCOUNT_NO: 832).exists?
      return true if account_no == 854 && data_in_row.where(ACCOUNT_NO: [836, 866]).exists?
      return true if account_no == 866 && data_in_row.where(ACCOUNT_NO: 836).exists?

      false
    end

    # JournalEntryDataListApplication::Create() - store pattern skip
    def skip_store_pattern_row?(pattern, company_no)
      return false unless pattern["JOURNAL_ENTRY_PATTERN_GROUP_NO"] == PATTERN_GROUP_STORE

      row_no = pattern["ROW_NO"]
      debit_account = pattern["DEBIT_ACCOUNT_NO"]

      if company_no == 1  # ウィーズ
        row_no == 8
      else
        (row_no == 4 && debit_account == 820) || row_no == 7
      end
    end

    # JournalEntryDataListApplication::GetAmmount()
    def amount_for(pattern, capture_row, side, account_no)
      base_amount = capture_row.amount.to_i
      pattern_group = pattern["JOURNAL_ENTRY_PATTERN_GROUP_NO"]

      if pattern_group == PATTERN_GROUP_STORE
        case pattern["ROW_NO"]
        when 4
          return nil if account_no.nil?

          return capture_row.amount.to_i if account_no == 823 && capture_row.company_no == 1  # 医薬品仕入/ウィーズ
          return capture_row.amount.to_i + capture_row.second_amount.to_i if account_no == 823
          return capture_row.second_amount.to_i if account_no == 820

          capture_row.amount.to_i + capture_row.second_amount.to_i
        when 7, 8
          return nil if account_no.nil?

          if account_no == 823  # 医薬品仕入
            capture_row.amount.to_i
          elsif [622, 620].include?(account_no)
            capture_row.second_amount.to_i
          else
            capture_row.amount.to_i + capture_row.second_amount.to_i
          end
        else
          capture_row.amount.to_i + capture_row.second_amount.to_i
        end
      elsif pattern_group == PATTERN_GROUP_LABOR
        same_row_scope = TrnCaptureData.where(
          CAPTURE_HISTORY_NO: capture_row.capture_history_no,
          ROW_NO: capture_row.row_no
        )

        case pattern["ROW_NO"]
        when 4
          return nil if account_no.nil?

          return same_row_scope.sum(:AMMOUNT).to_i if account_no == 418 # 関係会社未払金
          return amount_for_account(same_row_scope, 832) if account_no == 832
          return amount_for_account(same_row_scope, 866) if account_no == 866
          return amount_for_account(same_row_scope, 836) if account_no == 836
          return amount_for_account(same_row_scope, 854) if account_no == 854

          0
        when 7
          return nil if account_no.nil?

          return same_row_scope.sum(:AMMOUNT).to_i if account_no == 418 # 関係会社未払金

          if pattern["ABSTRACT"].to_s.include?("給与")
            return amount_for_account(same_row_scope, 832)
          elsif pattern["ABSTRACT"].to_s.include?("通勤手当")
            return amount_for_account(same_row_scope, 866)
          elsif pattern["ABSTRACT"].to_s.include?("法定福利費")
            return amount_for_account(same_row_scope, 836)
          elsif pattern["ABSTRACT"].to_s.include?("福利厚生費")
            return amount_for_account(same_row_scope, 854)
          end

          0
        else
          same_row_scope.sum(:AMMOUNT).to_i
        end
      else
        base_amount
      end
    end

    # JournalEntryDataListApplication::GetAmmount()
    def amount_for_account(scope, account_no)
      record = scope.find_by(ACCOUNT_NO: account_no)
      record&.amount.to_i
    end

    # JournalEntryDataListApplication::getSumAmmount()
    def grouped_amount(rows, key)
      rows.sum { |r| r[key].to_i }
    end

    # JournalEntryDataListApplication::getSumAmmount()
    def sum_amount(value)
      value.positive? ? value : nil
    end

    # JournalEntryDataListApplication::getDate()
    def date_for(pattern_no, accrual_month, payment_month, fund_transfer)
      case pattern_no
      when 0
        return nil unless accrual_month

        month_date = accrual_month.is_a?(Date) ? accrual_month : accrual_month.to_date
        adjust_weekend(month_date.end_of_month)
      when 1
        parse_fund_transfer_date(fund_transfer)
      when 2
        month_date = payment_month.is_a?(Date) ? payment_month : payment_month.to_date
        adjust_weekend(month_date.end_of_month)
      else
        nil
      end
    end

    # JournalEntryDataListApplication::checkWeekend()
    def adjust_weekend(date)
      return date unless date.respond_to?(:friday?)

      if date.saturday?
        date - 1.day
      elsif date.sunday?
        date - 2.days
      else
        date
      end
    end

    # JournalEntryDataListApplication::getDate()
    def parse_fund_transfer_date(value)
      return nil if value.blank?

      Date.strptime(value, "%Y-%m-%d")
    rescue ArgumentError
      nil
    end

    # JournalEntryDataListApplication::getCompanyNo()
    def company_for(pattern_company_no, data_company_no, capture_category_no)
      case pattern_company_no
      when 0
        data_company_no
      when 1
        capture_category(capture_category_no).supplier_company_no || 1
      else
        pattern_company_no
      end
    end

    # JournalEntryDataListApplication::getDepartmentNo()
    def department_for(pattern_department_no, department_no, company_no, capture_category_no, side)
      case pattern_department_no
      when 0
        department_no
      when 1
        case company_no
        when 1
          201
        when 792
          280
        when 808
          425
        else
          company_no
        end
      when 2
        category = capture_category(capture_category_no)
        side == "debit" ? category.debit_department_no : category.credit_department_no
      else
        pattern_department_no
      end
    end

    # JournalEntryDataListApplication::getAccountNo()
    def account_for(pattern_account_no, capture_category_no, side)
      case pattern_account_no
      when 2
        category = capture_category(capture_category_no)
        side == "debit" ? category.debit_account_no : category.credit_account_no
      else
        pattern_account_no
      end
    end

    # JournalEntryDataListApplication::getSubAccountNo()
    def sub_account_for(pattern_sub_account_no, capture_category_no, side)
      case pattern_sub_account_no
      when 999
        category = capture_category(capture_category_no)
        side == "debit" ? category.debit_sub_account_no : category.credit_sub_account_no
      else
        pattern_sub_account_no
      end
    end

    # JournalEntryDataListApplication::getSupplierNo()
    def supplier_for(pattern_supplier_id, company_no, supplier_id, capture_category_no)
      case pattern_supplier_id
      when 0
        supplier_id
      when 1
        company(company_no)&.supplier_id
      when 2
        capture_category(capture_category_no).supplier_id
      else
        pattern_supplier_id
      end
    end

    # JournalEntryDataListApplication::getTaxClass()
    def tax_class_for(pattern_tax_class_no, capture_category_no)
      case pattern_tax_class_no
      when 2
        capture_category(capture_category_no).tax_class_no
      else
        pattern_tax_class_no
      end
    end

    # JournalEntryDataListApplication::getTaxRate()
    def tax_rate_for(pattern_tax_rate_no, capture_category_no)
      case pattern_tax_rate_no
      when 2
        capture_category(capture_category_no).tax_rate_value
      else
        pattern_tax_rate_no
      end
    end

    # JournalEntryDataListApplication::getAbstract()
    def abstract_for(pattern_abstract, accrual_month, payment_month, store_no, company_no, capture_category_no)
      abstract = pattern_abstract.to_s.dup
      category = capture_category(capture_category_no)

      accrual_text = accrual_month ? format_month(accrual_month) : format_month(payment_month)
      payment_text = format_month(payment_month)
      store_name = department(store_no)&.department_name.to_s
      company_name = company(company_no)&.company_name.to_s

      abstract.gsub!("取引先別", category.abstract.to_s)
      abstract.gsub!("仕入先別", category.supplier_abstract.to_s)
      abstract.gsub!("発生月", accrual_text)
      abstract.gsub!("支払月", payment_text)
      abstract.gsub!("店舗名", store_name)
      abstract.gsub!("会社名", company_name)
      abstract
    end

    # JournalEntryDataListApplication::getDate()
    def format_month(value)
      date = value.is_a?(Date) ? value : value.to_date
      date.strftime("%-m月")
    end

    # JournalEntryDataListApplication::Create()
    def current_user_id
      return nil unless form.user.respond_to?(:user_id)

      form.user.user_id
    end

    def capture_category_cache
      @capture_category_cache ||= {}
    end

    def company_cache
      @company_cache ||= {}
    end

    def department_cache
      @department_cache ||= {}
    end

    def capture_category(number)
      capture_category_cache[number] ||= CaptureCategory.find(number)
    end

    def company(number)
      return nil if number.nil?

      company_cache[number] ||= Company.find_by(company_no: number)
    end

    def department(number)
      return nil if number.nil?

      department_cache[number] ||= Department.find_by(department_no: number)
    end
  end
end
