# frozen_string_literal: true

require "csv"
require "zip"

module JournalEntryData
  class Exporter
    include Support::AccountingItemLookup
    HEADER = "OBCD001, CSJS005, CSJS200, CSJS201, CSJS202, CSJS206, CSJS208, CSJS213,CSJS222,CSJS220, CSJS300, CSJS301, CSJS302, CSJS306, CSJS308, CSJS313,CSJS322,CSJS320, CSJS100"
    UTF8_BOM = "\uFEFF"
    ZIP_BASENAME = "取込用CSV"
    LOGISTICS_CATEGORY = 2
    LABOR_COST_CATEGORY = 23

    Row = Struct.new(
      :journal_entry_history_id,
      :company_code,
      :date,
      :department_code,
      :debit_department_code,
      :debit_account_code,
      :debit_account_sub_code,
      :debit_business_connection_code,
      :debit_amount,
      :debit_tax_class_code,
      :debit_tax_rate_id,
      :credit_department_code,
      :credit_account_code,
      :credit_account_sub_code,
      :credit_business_connection_code,
      :credit_amount,
      :credit_tax_class_code,
      :credit_tax_rate_id,
      :abstract,
      :row_no,
      :excel_row_no,
      :created_at,
      :capture_category_id,
      keyword_init: true
    )

    def self.call(form)
      new(form).call
    end

    def initialize(form)
      @form = form
    end

    # JournalEntryDataListApplication::CreateCsvFolder()/CreateZipFolder()
    def call
      rows = fetch_rows
      return failure("出力データはありませんでした。") if rows.empty?

      timestamp = Time.zone.now.strftime("%Y%m%d%H%M%S")
      zip_filename = "#{ZIP_BASENAME}_#{timestamp}.zip"

      payload = nil

      ActiveRecord::Base.transaction do
        csv_files = build_company_files(rows)
        zip_data = build_zip(csv_files)
        mark_histories_executed(rows.map(&:journal_entry_history_id).uniq)
        payload = { zip_data: zip_data, filename: zip_filename }
      end

      ServiceResult.new(success: true, payload: payload)
    rescue Support::AccountingItemLookup::MissingItemError => e
      Rails.logger.error("JournalEntryData::Exporter accounting item missing: #{e.message}")
      failure(e.message)
    rescue StandardError => e
      Rails.logger.error(
        "JournalEntryData::Exporter failed: #{e.class} #{e.message}\n#{e.backtrace.join("\n")}"
      )
      failure("CSV出力に失敗しました。")
    end

    private

    attr_reader :form

    def failure(message)
      ServiceResult.new(success: false, message: message)
    end

    # JournalEntryDataListApplication::CreateCsvFolder()
    def fetch_rows
      records_table = TrnJournalEntryRecord.table_name
      histories_table = TrnJournalEntryHistory.table_name

      scope = TrnJournalEntryRecord.joins(:journal_entry_history)
      if form.payment_month_date.present?
        scope = scope.where("#{histories_table}.payment_month = ?", form.payment_month_date)
      end
      scope = scope.where("#{histories_table}.capture_category_id = ?", form.supplier) unless form.supplier_all?
      scope = scope.where("#{histories_table}.execute_flag = ?", false) if form.except_already_output?

      scope = scope.order(<<~SQL.squish)
        #{histories_table}.id ASC,
        #{records_table}.row_no ASC,
        #{records_table}.department_code ASC,
        #{records_table}.created_at ASC
      SQL

      scope.pluck(
        "#{records_table}.journal_entry_history_id",
        "#{records_table}.company_code",
        "#{records_table}.date",
        "#{records_table}.department_code",
        "#{records_table}.debit_department_code",
        "#{records_table}.debit_account_code",
        "#{records_table}.debit_account_sub_code",
        "#{records_table}.debit_business_connection_code",
        "#{records_table}.debit_amount",
        "#{records_table}.debit_tax_class_code",
        "#{records_table}.debit_tax_rate_id",
        "#{records_table}.credit_department_code",
        "#{records_table}.credit_account_code",
        "#{records_table}.credit_account_sub_code",
        "#{records_table}.credit_business_connection_code",
        "#{records_table}.credit_amount",
        "#{records_table}.credit_tax_class_code",
        "#{records_table}.credit_tax_rate_id",
        "#{records_table}.abstract",
        "#{records_table}.row_no",
        "#{records_table}.excel_row_no",
        "#{records_table}.created_at",
        "#{histories_table}.capture_category_id"
      ).map do |values|
        Row.new(
          journal_entry_history_id: values[0],
          company_code: values[1],
          date: values[2],
          department_code: normalize_department_code(values[3]),
          debit_department_code: normalize_department_code(values[4]),
          debit_account_code: values[5],
          debit_account_sub_code: values[6],
          debit_business_connection_code: values[7],
          debit_amount: values[8],
          debit_tax_class_code: values[9],
          debit_tax_rate_id: values[10],
          credit_department_code: normalize_department_code(values[11]),
          credit_account_code: values[12],
          credit_account_sub_code: values[13],
          credit_business_connection_code: values[14],
          credit_amount: values[15],
          credit_tax_class_code: values[16],
          credit_tax_rate_id: values[17],
          abstract: values[18],
          row_no: values[19],
          excel_row_no: values[20],
          created_at: values[21],
          capture_category_id: values[22]
        )
      end
    end

    # JournalEntryDataListApplication::CreateCsvFolder()
    def build_company_files(rows)
      grouped = rows.group_by(&:company_code)
      company_names = Company.where(code: grouped.keys).pluck(:code, :name).to_h
      today_stamp = Time.zone.today.strftime("%Y%m%d")

      grouped.map do |company_code, company_rows|
        file_name = "#{company_names[company_code] || company_code}_#{today_stamp}.csv"
        [file_name, build_company_csv(company_rows)]
      end
    end

    # JournalEntryDataListApplication::CreateCsvFolder()
    def build_company_csv(rows)
      lines = [HEADER]
      section = "*"
      last_date = nil
      last_row_no = nil
      row_counter = 0

      rows.each_with_index do |row, index|
        ensure_accounting_item!(
          row.debit_account_code,
          row.debit_account_sub_code,
          "仕訳履歴ID=#{row.journal_entry_history_id} 行No=#{row.row_no} 借方"
        )
        ensure_accounting_item!(
          row.credit_account_code,
          row.credit_account_sub_code,
          "仕訳履歴ID=#{row.journal_entry_history_id} 行No=#{row.row_no} 貸方"
        )

        formatted_date = format_date(row.date)

        if last_date != formatted_date
          section = "*"
          last_date = formatted_date
          row_counter = 0
        end

        if row_counter >= 250
          section = "*"
          row_counter = 0
        end

        if last_row_no != row.row_no
          section = "*"
          last_row_no = row.row_no
          row_counter = 0
        end

        if requires_additional_split?(row)
          same_excel_count = rows[(index + 1)..].to_a.count do |other|
            other.created_at > row.created_at &&
              other.excel_row_no == row.excel_row_no &&
              other.row_no == row.row_no
          end
          if row_counter + same_excel_count >= 250
            section = "*"
            row_counter = 0
          end
        end

        debit_text = [
          row.debit_department_code,
          row.debit_account_code,
          row.debit_account_sub_code,
          2,
          row.debit_business_connection_code,
          row.debit_amount,
          row.debit_tax_class_code,
          rate_value_for(row.debit_tax_rate_id)
        ].map { |value| value.to_s }

        credit_text = [
          row.credit_department_code,
          row.credit_account_code,
          row.credit_account_sub_code,
          2,
          row.credit_business_connection_code,
          row.credit_amount,
          row.credit_tax_class_code,
          rate_value_for(row.credit_tax_rate_id)
        ].map { |value| value.to_s }

        line = ([section, formatted_date] + debit_text + credit_text + [row.abstract.to_s]).join(",")
        lines << line
        section = ""
        row_counter += 1
      end

      UTF8_BOM + lines.join("\n") + "\n"
    end

    # JournalEntryDataListApplication::CreateZipFolder()
    def build_zip(files)
      buffer = Zip::OutputStream.write_buffer do |zip|
        files.each do |filename, content|
          zip.put_next_entry(filename)
          zip.write(content)
        end
      end
      buffer.rewind
      buffer.read
    end

    def rate_value_for(tax_rate_id)
      return nil if tax_rate_id.blank?

      tax_rate_cache[tax_rate_id] ||= TaxRate.find_by(id: tax_rate_id)&.rate
    end

    def tax_rate_cache
      @tax_rate_cache ||= {}
    end

    # JournalEntryDataListApplication::ExecuteFlg()
    def mark_histories_executed(history_numbers)
      return if history_numbers.blank?

      TrnJournalEntryHistory.where(id: history_numbers).update_all(execute_flag: true)
    end

    # JournalEntryDataListApplication::CreateCsvFolder()
    def requires_additional_split?(row)
      [LOGISTICS_CATEGORY, LABOR_COST_CATEGORY].include?(row.capture_category_id.to_i)
    end

    def ensure_accounting_item!(account_code, account_sub_code, context)
      return if account_code.blank?
      return if accounting_item_for(account_code, account_sub_code)

      account_label = account_code.present? ? account_code : "-"
      sub_label = account_sub_code.present? ? account_sub_code : "-"
      raise Support::AccountingItemLookup::MissingItemError,
            "#{context} の勘定科目 (#{account_label}-#{sub_label}) が AccountingItem に存在しません。"
    end

    # JournalEntryDataListApplication::CreateCsvFolder()
    def format_date(value)
      return value.to_s unless value.respond_to?(:strftime)

      value.strftime("%Y/%m/%d")
    end

    def normalize_department_code(value)
      return nil if value.nil?

      string = value.to_s
      return string if string.blank?

      Integer(string, 10).to_s
    rescue ArgumentError, TypeError
      string
    end
  end
end
