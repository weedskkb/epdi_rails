# frozen_string_literal: true

require 'roo'
require 'roo-xls'

module CapturePaymentData
  class Capture
    CATEGORY_WHOLESALE = 1
    CATEGORY_STORE = 16
    CATEGORY_FIXED = 24
    CATEGORY_EXPENSE_SUMMARY = 23

    class InvalidFileError < StandardError; end

    def self.call(view_model)
      new(view_model).call
    end

    def initialize(view_model)
      @view_model = view_model
      @base_history = nil
    end

    # CapturePaymentDataApplication::Capture()
    def call
      return failure('セッションが無効です。') if view_model.user.blank?

      view_model.valid?
      ensure_month_requirements
      ensure_history_uniqueness unless view_model.overwrite?
      return failure(view_model.errors.full_messages.join("\n")) if view_model.errors.any?

      sheets = load_sheets
      ensure_category_match(sheets)
      ensure_departments_exist(sheets)
      return failure(view_model.errors.full_messages.join("\n")) if view_model.errors.any?

      ActiveRecord::Base.transaction do
        process_overwrite if view_model.overwrite?
        record_initial_history
        import_sheets(sheets)
      end

      success('取込が完了しました。')
    rescue InvalidFileError => e
      view_model.errors.add(:file, e.message)
      failure('入力内容を確認してください')
    rescue StandardError => e
      Rails.logger.error("Capture failed: #{e.class} #{e.message}\n#{e.backtrace.join("\n")}")
      view_model.errors.add(:base, '取込に失敗しました。')
      failure("取込に失敗しました。#{e.message}")
    end

    private

    attr_reader :view_model

    def success(message)
      ServiceResult.new(success: true, message: message)
    end

    def failure(message)
      ServiceResult.new(success: false, message: message, payload: { view_model: view_model })
    end

    def user_id
      view_model.user&.id
    end

    def capture_category
      view_model.capture_category.to_i
    end

    def target_month_value
      view_model.target_month.to_s
    end

    def accrual_month_value
      view_model.accrual_month.to_s.presence
    end

    def payment_month_value
      view_model.payment_month.to_s.presence
    end

    # CapturePaymentDataApplication::CheckMonth()
    def ensure_month_requirements
      case capture_category
      when CATEGORY_WHOLESALE, CATEGORY_STORE, CATEGORY_FIXED
        if target_month_value.blank? && view_model.errors[:target_month].blank?
          view_model.errors.add(:target_month, '年月選択は必須です。')
        end
      else
        view_model.errors.add(:accrual_month, '発生月を入力してください。') if accrual_month_value.blank?
        view_model.errors.add(:payment_month, '支払月を入力してください。') if payment_month_value.blank?
      end
    end

    # CapturePaymentDataApplication::CheckHistory()
    def ensure_history_uniqueness
      return if capture_category.zero?

      exists = case capture_category
               when CATEGORY_STORE, CATEGORY_FIXED
                 TrnCaptureHistory.exists?(CAPTURE_CATEGORY_NO: capture_category, ACCRUAL_MONTH: target_month_value)
               when CATEGORY_WHOLESALE
                 pm = next_month_string(target_month_value)
                 TrnCaptureHistory.exists?(CAPTURE_CATEGORY_NO: capture_category, PAYMENT_MONTH: pm)
               else
                 TrnCaptureHistory.exists?(CAPTURE_CATEGORY_NO: capture_category,
                                          ACCRUAL_MONTH: accrual_month_value,
                                          PAYMENT_MONTH: payment_month_value)
               end
      view_model.errors.add(:base, '既に取込済みです。') if exists
    end

    # CapturePaymentDataApplication::Save() - load Excel sheets
    def load_sheets
      files = uploaded_files
      files = files.filter{ |file| ['xlsx', 'xls'].include?(detect_extension(file).to_s.downcase) }
      raise InvalidFileError, 'ファイルを選択してください。' if files.empty?

      files.map { |file| select_worksheet(file) }
    rescue InvalidFileError
      raise
    rescue StandardError
      raise InvalidFileError, 'Excelファイルの読み込みに失敗しました。'
    end

    def uploaded_files
      file = view_model.file
      return [] if file.blank?

      if file.is_a?(Array)
        # file
        file[1..]
      elsif file.respond_to?(:values)
        file.values
      else
        [file]
      end
    end

    # CapturePaymentDataApplication::Save() - select worksheet
    def select_worksheet(file)
      temp = file.respond_to?(:tempfile) ? file.tempfile : file
      temp.rewind if temp.respond_to?(:rewind)
      workbook = open_workbook(temp.path, detect_extension(file))

      sheet_name = if capture_category == CATEGORY_WHOLESALE
                     name = wholesale_sheet_name
                     workbook.sheets.include?(name) ? name : workbook.sheets.first
                   else
                     workbook.sheets.first
                   end

      raise InvalidFileError, '対象シートが存在しません。' unless sheet_name

      workbook.default_sheet = sheet_name
      workbook
    end

    def open_workbook(path, extension)
      candidates = extension ? [extension] : [:xlsx, :xls]

      candidates.each do |ext|
        begin
          return Roo::Spreadsheet.open(path, extension: ext)
        rescue StandardError
          next
        end
      end

      raise InvalidFileError, 'Excelファイルの読み込みに失敗しました。'
    end

    def detect_extension(file)
      filename = if file.respond_to?(:original_filename)
                   file.original_filename.to_s
                 elsif file.respond_to?(:path)
                   File.basename(file.path.to_s)
                 else
                   ''
                 end

      ext = File.extname(filename).delete('.').downcase

      case ext
      when 'xlsx', 'xlsm'
        :xlsx
      when 'xls'
        :xls
      else
        nil
      end
    end

    # CapturePaymentDataApplication::Save() - sheet naming
    def wholesale_sheet_name
      date = parse_month_string(target_month_value)
      return '' unless date

      "#{date.next_month.strftime('%-m月')}支払い一覧店舗別"
    end

    def parse_month_string(value)
      return nil if value.blank?

      Date.strptime(value, '%Y-%m')
    rescue ArgumentError
      nil
    end

    # CapturePaymentDataApplication::CheckCategory()
    def ensure_category_match(sheets)
      return if [CATEGORY_WHOLESALE, CATEGORY_STORE, CATEGORY_FIXED].include?(capture_category)
      return if sheets.empty?

      value = cell_string(sheets.first, 0, 0)
      view_model.errors.add(:base, '取引先とエクセルの区分が間違っています。') unless value == capture_category.to_s
    end

    # CapturePaymentDataApplication::CheckDepartment()
    def ensure_departments_exist(sheets)
      start_row = case capture_category
                  when CATEGORY_WHOLESALE then 5
                  when CATEGORY_STORE then 11
                  when CATEGORY_FIXED then 8
                  when CATEGORY_EXPENSE_SUMMARY then 3
                  else 2
                  end

      missing = nil
      sheets.each do |sheet|
        (start_row..last_row_index(sheet)).each do |row_idx|
          department_id = cell_integer(sheet, row_idx, 0)
          next unless department_id

          unless Department.exists?(id: department_id)
            missing = department_id
            break
          end
        end
        break if missing
      end

      view_model.errors.add(:base, "登録されていない店舗番号があります。(店舗番号：#{missing})") if missing
    end

    # CapturePaymentDataApplication::Overwrite()
    def process_overwrite
      history_numbers = case capture_category
                        when CATEGORY_STORE, CATEGORY_FIXED
                          TrnCaptureHistory.where(CAPTURE_CATEGORY_NO: capture_category,
                                                   ACCRUAL_MONTH: target_month_value).pluck(:CAPTURE_HISTORY_NO)
                        when CATEGORY_WHOLESALE
                          pm = next_month_string(target_month_value)
                          TrnCaptureHistory.where(CAPTURE_CATEGORY_NO: capture_category,
                                                  PAYMENT_MONTH: pm).pluck(:CAPTURE_HISTORY_NO)
                        else
                          TrnCaptureHistory.where(CAPTURE_CATEGORY_NO: capture_category,
                                                  ACCRUAL_MONTH: accrual_month_value,
                                                  PAYMENT_MONTH: payment_month_value).pluck(:CAPTURE_HISTORY_NO)
                        end

      history_numbers.each do |history_no|
        TrnJournalEntryHistory.where(CAPTURE_HISTORY_NO: history_no).find_each do |journal_history|
          TrnJournalEntryData.where(JOURNAL_ENTRY_HISTORY_NO: journal_history.journal_entry_history_no).delete_all
          journal_history.destroy!
        end
        TrnCaptureData.where(CAPTURE_HISTORY_NO: history_no).delete_all
        TrnCaptureHistory.where(CAPTURE_HISTORY_NO: history_no).delete_all
      end
    end

    # CapturePaymentDataApplication::RecordHistory() - initialize
    def record_initial_history
      target_month = parse_month_string(target_month_value)
      payment_month = parse_month_string(payment_month_value)
      accrual_month = parse_month_string(accrual_month_value)

      @base_history = case capture_category
                      when CATEGORY_STORE
                        nil
                      when CATEGORY_FIXED
                        create_history(accrual_month: target_month, payment_month: target_month)
                      when CATEGORY_WHOLESALE
                        create_history(payment_month: target_month.next_month)
                      else
                        create_history(accrual_month: accrual_month, payment_month: payment_month)
                      end
    end

    # CapturePaymentDataApplication::RecordHistory() - create entry
    def create_history(accrual_month: nil, payment_month:)
      TrnCaptureHistory.create!(
        capture_category_no: capture_category,
        accrual_month: accrual_month,
        payment_month: payment_month,
        lock_flg: false,
        create_user_id: user_id,
        create_date: Time.zone.now
      )
    end

    # CapturePaymentDataApplication::Capture() - dispatch
    def import_sheets(sheets)
      case capture_category
      when CATEGORY_STORE
        import_store_data(sheets)
      when CATEGORY_FIXED
        import_fixed_data(sheets)
      when CATEGORY_WHOLESALE
        import_wholesale_data(sheets)
      when CATEGORY_EXPENSE_SUMMARY
        import_expense_summary_data(sheets)
      else
        import_shared_data(sheets)
      end
    end

    # CapturePaymentDataApplication::Capture() - store branch
    def import_store_data(sheets)
      sheets.each do |sheet|
        last_row = last_row_index(sheet)
        last_column = last_column_index(sheet, 0) - 1
        (11..last_row).each do |row_idx|
          department_id = cell_integer(sheet, row_idx, 0)
          next unless department_id

          company_id = department_company_id(department_id)
          (3...last_column).each do |col_idx|
            amount = cell_integer(sheet, row_idx, col_idx)
            supplier_id = cell_integer(sheet, 9, col_idx)
            next unless amount && supplier_id

            term = cell_integer(sheet, 4, col_idx) || 0
            payment_month = payment_month_from_term(target_month_value, term)
            history = find_or_create_store_history(payment_month)

            account_no = cell_integer(sheet, 5, col_idx)
            sub_account_no = cell_integer(sheet, 7, col_idx)
            list_cd = [account_no, sub_account_no, supplier_id].map { |v| v.to_i }.join('-')

            create_capture_data(
              capture_history_no: history.capture_history_no,
              row_no: row_idx + 1,
              company_id: company_id,
              department_id: department_id,
              supplier_id: supplier_id,
              account_no: account_no,
              sub_account_no: sub_account_no,
              list_cd: list_cd,
              amount: amount,
              second_amount: 0,
              tax_rate_id: tax_rate_for(cell_string(sheet, 3, col_idx)),
              tax_class_id: tax_class_for(cell_string(sheet, 3, col_idx))
            ) if amount != 0
          end
        end
      end
    end

    # CapturePaymentDataApplication::Capture() - fixed branch
    def import_fixed_data(sheets)
      history_no = base_history_id
      sheets.each do |sheet|
        last_row = last_row_index(sheet)
        last_column = last_column_index(sheet, 0) - 1
        (8..last_row).each do |row_idx|
          department_id = cell_integer(sheet, row_idx, 0)
          supplier_id = cell_integer(sheet, row_idx, 3)
          next unless department_id && supplier_id

          company_id = department_company_id(department_id)
          (5...last_column).each do |col_idx|
            amount = cell_integer(sheet, row_idx, col_idx)
            next unless amount

            account_no = cell_integer(sheet, 3, col_idx)
            sub_account_no = cell_integer(sheet, 5, col_idx)
            list_cd = [account_no, sub_account_no, supplier_id].map { |v| v.to_i }.join('-')

            create_capture_data(
              capture_history_no: history_no,
              row_no: row_idx + 1,
              company_id: company_id,
              department_id: department_id,
              supplier_id: supplier_id,
              account_no: account_no,
              sub_account_no: sub_account_no,
              list_cd: list_cd,
              amount: amount,
              second_amount: 0
            ) if amount != 0
          end
        end
      end
    end

    # CapturePaymentDataApplication::Capture() - wholesale branch
    def import_wholesale_data(sheets)
      history_no = base_history_id
      sheets.each do |sheet|
        last_row = last_row_index(sheet)
        last_column = last_column_index(sheet, 3) - 1
        (5..last_row).each do |row_idx|
          department_id = cell_integer(sheet, row_idx, 0)
          next unless department_id

          company_id = department_company_id(department_id)
          (2...last_column).each do |col_idx|
            amount = cell_integer(sheet, row_idx, col_idx)
            next unless amount

            supplier_id = cell_integer(sheet, 2, col_idx)
            list_cd = "--#{supplier_id}"

            # 勘定科目はここでは設定しない
            create_capture_data(
              capture_history_no: history_no,
              row_no: row_idx + 1,
              company_id: company_id,
              department_id: department_id,
              supplier_id: supplier_id,
              list_cd: list_cd,
              amount: amount,
              second_amount: 0
            ) if amount != 0
          end
        end
      end
    end

    # CapturePaymentDataApplication::Capture() - expense summary branch
    def import_expense_summary_data(sheets)
      history_no = base_history_id
      sheets.each do |sheet|
        last_row = last_row_index(sheet)
        (3..last_row).each do |row_idx|
          department_id = cell_integer(sheet, row_idx, 0)
          next unless department_id

          company_id = department_company_id(department_id)
          (2..5).each do |col_idx|
            amount = cell_integer(sheet, row_idx, col_idx)
            next unless amount

            account_no = expense_summary_account_for(col_idx)
            create_capture_data(
              capture_history_no: history_no,
              row_no: row_idx + 1,
              company_id: company_id,
              department_id: department_id,
              account_no: account_no,
              list_cd: capture_category.to_s,
              amount: amount,
              second_amount: 0
            ) if amount != 0
          end
        end
      end
    end

    # CapturePaymentDataApplication::Capture() - shared branch
    def import_shared_data(sheets)
      history_no = base_history_id
      category = capture_category_record
      sheets.each do |sheet|
        last_row = last_row_index(sheet)
        (1..last_row).each do |row_idx|
          department_id = cell_integer(sheet, row_idx, 0)
          next unless department_id

          primary_amount = cell_integer(sheet, row_idx, 2)
          secondary_amount = cell_integer(sheet, row_idx, 3)
          next unless primary_amount || secondary_amount

          amount = primary_amount || 0
          second_amount = secondary_amount || 0

          create_capture_data(
            capture_history_no: history_no,
            row_no: row_idx + 1,
            company_id: department_company_id(department_id),
            department_id: department_id,
            supplier_id: category.supplier_id,
            account_no: category.debit_account_no,
            sub_account_no: category.debit_sub_account_no,
            list_cd: capture_category.to_s,
            amount: amount,
            second_amount: second_amount
          ) # if amount != 0
        end
      end
    end

    # CapturePaymentDataApplication::existHistory()/getHistoryNo()
    def find_or_create_store_history(payment_month)
      TrnCaptureHistory.find_or_create_by!(
        CAPTURE_CATEGORY_NO: capture_category,
        ACCRUAL_MONTH: parse_month_string(target_month_value),
        PAYMENT_MONTH: parse_month_string(payment_month)
      ) do |history|
        history.lock_flg = false
        history.create_user_id = user_id
        history.create_date = Time.zone.now
      end
    end

    # CapturePaymentDataApplication::getHistoryNo()
    def base_history_id
      @base_history&.capture_history_no
    end

    def create_capture_data(attrs)
      TrnCaptureData.create!(
        capture_history_no: attrs[:capture_history_no],
        row_no: attrs[:row_no],
        company_id: attrs[:company_id],
        department_id: attrs[:department_id],
        supplier_id: attrs[:supplier_id],
        account_no: attrs[:account_no],
        sub_account_no: attrs[:sub_account_no],
        list_cd: attrs[:list_cd],
        amount: attrs[:amount],
        second_amount: attrs[:second_amount] || 0,
        tax_rate_id: attrs[:tax_rate_id],
        tax_class_id: attrs[:tax_class_id],
        create_user_id: user_id,
        create_date: Time.zone.now
      )
    end

    def department_company_id(department_id)
      Department.find(department_id).company_id
    end

    # CapturePaymentDataApplication::getPaymentMonth()
    def payment_month_from_term(accrual_month, term)
      date = parse_month_string(accrual_month)
      return accrual_month unless date

      offset = term.to_i
      offset = 1 if offset.zero?
      date.advance(months: offset).strftime('%Y-%m')
    end

    # CapturePaymentDataApplication::CheckHistory() - month increment
    def next_month_string(value)
      date = parse_month_string(value)
      return value unless date

      date.next_month.strftime('%Y-%m')
    end

    # TODO: 変更の必要あり
    # CapturePaymentDataApplication::getTaxRate()
    def tax_rate_for(value)
      # value.present? ? 8 : nil
      return 8 unless value.nil?
    end

    # CapturePaymentDataApplication::getTaxClass()
    def tax_class_for(value)
      case value.to_s
      when '8' then 0
      when 'K' then 1
      else nil
      end
    end

    def expense_summary_account_for(column_index)
      case column_index
      when 2 then 832 # 給与手当
      when 3 then 836 # 法定福利費
      when 4 then 866 # 旅費交通費
      when 5 then 854 # 福利厚生費
      else nil
      end
    end

    def capture_category_record
      @capture_category_record ||= CaptureCategory.find(capture_category)
    end

    # CapturePaymentDataApplication::GetCellValue()
    def cell_value(sheet, row_idx, col_idx)
      sheet.cell(row_idx + 1, col_idx + 1)
    end

    # CapturePaymentDataApplication::GetCellValue() - numeric conversion
    def cell_integer(sheet, row_idx, col_idx)
      value = cell_value(sheet, row_idx, col_idx)
      return nil if value.nil?

      if value.is_a?(Numeric)
        return nil if value.zero?
        value.ceil
      elsif value.is_a?(String)
        stripped = value.delete(',')
        return nil if stripped.empty?
        begin
          number = Float(stripped)
          return nil if number.zero?
          number.ceil
        rescue ArgumentError, TypeError
          int_value = Integer(stripped, exception: false)
          return nil if int_value.nil? || int_value.zero?
          int_value
        end
      end
    end

    # CapturePaymentDataApplication::GetCellValue() - string conversion
    def cell_string(sheet, row_idx, col_idx)
      value = cell_value(sheet, row_idx, col_idx)
      return '' if value.nil?

      if value.is_a?(Numeric)
        value.round.to_s
      else
        value.to_s
      end
    end

    def last_row_index(sheet)
      last = sheet.last_row
      return 0 unless last

      (last - 1).downto(0) do |idx|
        row = sheet.row(idx + 1)
        return idx if row&.any? { |value| value_present?(value) }
      end

      0
    end

    def last_column_index(sheet, reference_row)
      row = sheet.row(reference_row + 1)
      return 0 if row.nil? || row.empty?

      length = row.size
      while length.positive? && !value_present?(row[length - 1])
        length -= 1
      end

      length
    end

    def value_present?(value)
      return false if value.nil?
      return value.present? if value.respond_to?(:present?)

      !(value.is_a?(String) && value.strip.empty?)
    end
  end
end
