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
      scope = scope.where(capture_category_id: form.supplier) unless form.supplier_all?

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
          capture_category_id: capture_history.capture_category_id,
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
        category = capture_category_record(history.capture_category_id)

        patterns = JournalEntryPattern
                   .where(JOURNAL_ENTRY_PATTERN_GROUP_NO: category.journal_entry_pattern_group_no)
                   .order(:ROW_NO, :JOURNAL_ENTRY_PATTERN_NO)

        capture_rows = TrnCaptureData
                       .where(CAPTURE_HISTORY_NO: history.capture_history_no)
                       .order(:department_id, :ROW_NO)

        grouping_rows = []
        capture_rows.each do |row|
          next if skip_expense_summary_row?(category.id, row)

          patterns.each do |pattern|
            next if skip_store_pattern_row?(pattern, row.company_id)

            debit_account_code = account_for(pattern.debit_account_code, category.id, "debit")
            credit_account_code = account_for(pattern.credit_account_code, category.id, "credit")

            debit_amount = amount_for(pattern, row, "debit", debit_account_code)
            credit_amount = amount_for(pattern, row, "credit", credit_account_code)

            entry_hash = build_entry_hash(
              history: history,
              pattern: pattern,
              capture_category: category,
              capture_row: row,
              debit_account_code: debit_account_code,
              credit_account_code: credit_account_code,
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
            row[:debit_department_id],
            row[:debit_account_code],
            row[:debit_account_sub_code],
            row[:debit_supplier_id],
            row[:credit_department_id],
            row[:credit_account_code],
            row[:credit_account_sub_code],
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
            company_id: 1,  # ウィーズ
            department_id: 201,
            debit_department_id: key[2],
            debit_account_code: key[3],
            debit_account_sub_code: key[4],
            debit_supplier_id: key[5],
            debit_amount: sum_amount(debit_sum),
            credit_department_id: key[6],
            credit_account_code: key[7],
            credit_account_sub_code: key[8],
            credit_supplier_id: key[9],
            credit_amount: sum_amount(credit_sum),
            abstract: key[10],
            debit_tax_class_id: nil,
            debit_tax_rate_id: nil,
            credit_tax_class_id: nil,
            credit_tax_rate_id: nil
          )
        end
    end

    # JournalEntryDataListApplication::Create()
    def build_entry_hash(history:, pattern:, capture_category:, capture_row:, debit_account_code:, credit_account_code:, debit_amount:, credit_amount:)
      {
        journal_entry_history_no: history.journal_entry_history_no,
        row_no: pattern["ROW_NO"],
        excel_row_no: capture_row.row_no,
        date: date_for(pattern["DATE_PATTERN_NO"], history.accrual_month, history.payment_month, form.fund_transfer_date),
        company_id: company_for(pattern.company_id, capture_row.company_id, capture_category.id),
        department_id: capture_row.department_id,
        debit_department_id: department_for(pattern.debit_department_id, capture_row.department_id, capture_row.company_id, capture_category.id, "debit"),
        debit_account_code: debit_account_code,
        debit_account_sub_code: sub_account_for(pattern.debit_account_sub_code,
                                               capture_category.id, "debit"),
        debit_supplier_id: supplier_for(pattern.debit_supplier_id, capture_row.company_id, capture_row.supplier_id, capture_category.id),
        debit_amount: debit_amount,
        debit_tax_class_id: tax_class_for(pattern.debit_tax_class_id, capture_category.id),
        debit_tax_rate_id: tax_rate_for(pattern.debit_tax_rate_id, capture_category.id),
        credit_department_id: department_for(pattern.credit_department_id, capture_row.department_id, capture_row.company_id, capture_category.id, "credit"),
        credit_account_code: credit_account_code,
        credit_account_sub_code: sub_account_for(pattern.credit_account_sub_code,
                                                 capture_category.id, "credit"),
        credit_supplier_id: supplier_for(pattern.credit_supplier_id, capture_row.company_id, capture_row.supplier_id, capture_category.id),
        credit_amount: credit_amount,
        credit_tax_class_id: tax_class_for(pattern.credit_tax_class_id, capture_category.id),
        credit_tax_rate_id: tax_rate_for(pattern.credit_tax_rate_id, capture_category.id),
        abstract: abstract_for(
          pattern["ABSTRACT"].to_s,
          history.accrual_month,
          history.payment_month,
          capture_row.department_id,
          capture_row.company_id,
          capture_category.id
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
        company_id: attributes[:company_id],
        department_id: attributes[:department_id],
        debit_department_id: attributes[:debit_department_id],
        debit_account_code: attributes[:debit_account_code],
        debit_account_sub_code: attributes[:debit_account_sub_code],
        debit_supplier_id: attributes[:debit_supplier_id],
        debit_amount: attributes[:debit_amount],
        debit_tax_class_id: attributes[:debit_tax_class_id],
        debit_tax_rate_id: attributes[:debit_tax_rate_id],
        credit_department_id: attributes[:credit_department_id],
        credit_account_code: attributes[:credit_account_code],
        credit_account_sub_code: attributes[:credit_account_sub_code],
        credit_supplier_id: attributes[:credit_supplier_id],
        credit_amount: attributes[:credit_amount],
        credit_tax_class_id: attributes[:credit_tax_class_id],
        credit_tax_rate_id: attributes[:credit_tax_rate_id],
        abstract: attributes[:abstract],
        create_user_id: current_user_id,
        create_date: Time.zone.now
      )
    end

    # JournalEntryDataListApplication::Create() - expense summary skip
    def skip_expense_summary_row?(capture_category_id, capture_row)
      return false unless capture_category_id == CATEGORY_EXPENSE_SUMMARY

      account_code = capture_row.account_code
      row_number = capture_row.row_no

      # 832: 給与手当
      # 836: 法定福利費
      # 866: 旅費交通費
      # 854: 福利厚生費
      skip_accounts = [836, 866, 854]
      return false unless skip_accounts.include?(account_code)

      data_in_row = TrnCaptureData.where(
        CAPTURE_HISTORY_NO: capture_row.capture_history_no,
        ROW_NO: row_number
      )

      return true if data_in_row.where(account_code: 832).exists?
      return true if account_code == 854 && data_in_row.where(account_code: [836, 866]).exists?
      return true if account_code == 866 && data_in_row.where(account_code: 836).exists?

      false
    end

    # JournalEntryDataListApplication::Create() - store pattern skip
    def skip_store_pattern_row?(pattern, company_id)
      return false unless pattern["JOURNAL_ENTRY_PATTERN_GROUP_NO"] == PATTERN_GROUP_STORE

      row_no = pattern["ROW_NO"]
      debit_account = pattern.debit_account_code

      if company_id == 1  # ウィーズ
        row_no == 8
      else
        (row_no == 4 && debit_account == 820) || row_no == 7
      end
    end

    # JournalEntryDataListApplication::GetAmmount()
    def amount_for(pattern, capture_row, side, account_code)
      base_amount = capture_row.amount.to_i
      pattern_group = pattern["JOURNAL_ENTRY_PATTERN_GROUP_NO"]

      if pattern_group == PATTERN_GROUP_STORE
        case pattern["ROW_NO"]
        when 4
          return nil if account_code.nil?

          return capture_row.amount.to_i if account_code == 823 && capture_row.company_id == 1  # 医薬品仕入/ウィーズ
          return capture_row.amount.to_i + capture_row.second_amount.to_i if account_code == 823
          return capture_row.second_amount.to_i if account_code == 820

          capture_row.amount.to_i + capture_row.second_amount.to_i
        when 7, 8
          return nil if account_code.nil?

          if account_code == 823  # 医薬品仕入
            capture_row.amount.to_i
          elsif [622, 620].include?(account_code)
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
          return nil if account_code.nil?

          return same_row_scope.sum(:AMMOUNT).to_i if account_code == 418 # 関係会社未払金
          return amount_for_account(same_row_scope, 832) if account_code == 832
          return amount_for_account(same_row_scope, 866) if account_code == 866
          return amount_for_account(same_row_scope, 836) if account_code == 836
          return amount_for_account(same_row_scope, 854) if account_code == 854

          0
        when 7
          return nil if account_code.nil?

          return same_row_scope.sum(:AMMOUNT).to_i if account_code == 418 # 関係会社未払金

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
    def amount_for_account(scope, account_code)
      record = scope.find_by(account_code: account_code)
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
    def company_for(pattern_company_value, data_company_id, capture_category_id)
      case pattern_company_value
      when 0
        data_company_id
      when 1
        capture_category_record(capture_category_id).supplier_company_id || 1
      else
        pattern_company_value
      end
    end

    # JournalEntryDataListApplication::getDepartmentNo()
    def department_for(pattern_department_id, department_id, company_id, capture_category_id, side)
      case pattern_department_id
      when 0
        department_id
      when 1
        case company_id
        when 1
          201
        when 792
          280
        when 808
          425
        else
          company_id
        end
      when 2
        category = capture_category_record(capture_category_id)
        side == "debit" ? category.debit_department_id : category.credit_department_id
      else
        pattern_department_id
      end
    end

    # JournalEntryDataListApplication::getAccountNo()
    def account_for(pattern_account_code, capture_category_id, side)
      case pattern_account_code
      when 2
        category = capture_category_record(capture_category_id)
        side == "debit" ? category.debit_account_code : category.credit_account_code
      else
        pattern_account_code
      end
    end

    # JournalEntryDataListApplication::getSubAccountNo()
    def sub_account_for(pattern_sub_code, capture_category_id, side)
      case pattern_sub_code
      when 999
        category = capture_category_record(capture_category_id)
        side == "debit" ? category.debit_account_sub_code : category.credit_account_sub_code
      else
        pattern_sub_code
      end
    end

    # JournalEntryDataListApplication::getSupplierNo()
    def supplier_for(pattern_supplier_id, company_id, supplier_id, capture_category_id)
      case pattern_supplier_id
      when 0
        supplier_id
      when 1
        company(company_id)&.supplier_id
      when 2
        capture_category_record(capture_category_id).supplier_id
      else
        pattern_supplier_id
      end
    end

    # JournalEntryDataListApplication::getTaxClass()
    def tax_class_for(pattern_tax_class_id, capture_category_id)
      case pattern_tax_class_id
      when 2
        capture_category_record(capture_category_id).tax_class_id
      else
        pattern_tax_class_id
      end
    end

    # JournalEntryDataListApplication::getTaxRate()
    PATTERN_TAX_RATE_USE_CAPTURE_CATEGORY = 2

    def tax_rate_for(pattern_tax_rate_id, capture_category_id)
      return nil if pattern_tax_rate_id.blank?

      rate_id = pattern_tax_rate_id.to_i
      if rate_id == PATTERN_TAX_RATE_USE_CAPTURE_CATEGORY
        capture_category_record(capture_category_id).tax_rate_id
      else
        rate_id
      end
    end

    # JournalEntryDataListApplication::getAbstract()
    def abstract_for(pattern_abstract, accrual_month, payment_month, store_no, company_id, capture_category_id)
      abstract = pattern_abstract.to_s.dup
      category = capture_category_record(capture_category_id)

      accrual_text = accrual_month ? format_month(accrual_month) : format_month(payment_month)
      payment_text = format_month(payment_month)
      store_name = department(store_no)&.department_name.to_s
      company_name = company(company_id)&.name.to_s

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
      return nil unless form.user.respond_to?(:id)

      form.user.id
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

    def capture_category_record(id)
      capture_category_cache[id] ||= CaptureCategory.find(id)
    end

    def company(number)
      return nil if number.nil?

      company_cache[number] ||= Company.find_by(id: number)
    end

    def department(number)
      return nil if number.nil?

      department_cache[number] ||= Department.find_by(id: number)
    end
  end
end
