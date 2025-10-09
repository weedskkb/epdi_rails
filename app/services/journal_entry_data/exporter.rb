# frozen_string_literal: true

require "csv"
require "zip"

module JournalEntryData
  class Exporter
    HEADER = "OBCD001, CSJS005, CSJS200, CSJS201, CSJS202, CSJS206, CSJS208, CSJS213,CSJS222,CSJS220, CSJS300, CSJS301, CSJS302, CSJS306, CSJS308, CSJS313,CSJS322,CSJS320, CSJS100"
    UTF8_BOM = "\uFEFF"
    ZIP_BASENAME = "取込用CSV"
    LOGISTICS_CATEGORY = 2
    LABOR_COST_CATEGORY = 23

    Row = Struct.new(
      :journal_entry_history_no,
      :company_no,
      :date,
      :department_no,
      :debit_department_no,
      :debit_account_no,
      :debit_sub_account_no,
      :debit_supplier_no,
      :debit_amount,
      :debit_tax_class_no,
      :debit_tax_rate_no,
      :credit_department_no,
      :credit_account_no,
      :credit_sub_account_no,
      :credit_supplier_no,
      :credit_amount,
      :credit_tax_class_no,
      :credit_tax_rate_no,
      :abstract,
      :row_no,
      :excel_row_no,
      :create_date,
      :capture_category_no,
      keyword_init: true
    )

    def self.call(form)
      new(form).call
    end

    def initialize(form)
      @form = form
    end

    def call
      rows = fetch_rows
      return failure("出力データはありませんでした。") if rows.empty?

      timestamp = Time.zone.now.strftime("%Y%m%d%H%M%S")
      zip_filename = "#{ZIP_BASENAME}_#{timestamp}.zip"

      payload = nil

      ActiveRecord::Base.transaction do
        csv_files = build_company_files(rows)
        zip_data = build_zip(csv_files)
        mark_histories_executed(rows.map(&:journal_entry_history_no).uniq)
        payload = { zip_data: zip_data, filename: zip_filename }
      end

      ServiceResult.new(success: true, payload: payload)
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

    def fetch_rows
      scope = TrnJournalEntryData.joins(:journal_entry_history)
      if form.payment_month_date.present?
        scope = scope.where("TRN_JOURNAL_ENTRY_HISTORY.PAYMENT_MONTH = ?", form.payment_month_date)
      end
      scope = scope.where("TRN_JOURNAL_ENTRY_HISTORY.CAPTURE_CATEGORY_NO = ?", form.supplier) unless form.supplier_all?
      scope = scope.where("TRN_JOURNAL_ENTRY_HISTORY.EXECUTE_FLG = ?", false) if form.except_already_output?

      scope = scope.order(<<~SQL.squish)
        TRN_JOURNAL_ENTRY_HISTORY.JOURNAL_ENTRY_HISTORY_NO ASC,
        TRN_JOURNAL_ENTRY_DATA.ROW_NO ASC,
        TRN_JOURNAL_ENTRY_DATA.DEPARTMENT_NO ASC,
        TRN_JOURNAL_ENTRY_DATA.CREATE_DATE ASC
      SQL

      scope.pluck(
        "TRN_JOURNAL_ENTRY_DATA.JOURNAL_ENTRY_HISTORY_NO",
        "TRN_JOURNAL_ENTRY_DATA.COMPANY_NO",
        "TRN_JOURNAL_ENTRY_DATA.DATE",
        "TRN_JOURNAL_ENTRY_DATA.DEPARTMENT_NO",
        "TRN_JOURNAL_ENTRY_DATA.DEBIT_DEPARTMENT_NO",
        "TRN_JOURNAL_ENTRY_DATA.DEBIT_ACCOUNT_NO",
        "TRN_JOURNAL_ENTRY_DATA.DEBIT_SUB_ACCOUNT_NO",
        "TRN_JOURNAL_ENTRY_DATA.DEBIT_SUPPLIER_NO",
        "TRN_JOURNAL_ENTRY_DATA.DEBIT_AMMOUNT",
        "TRN_JOURNAL_ENTRY_DATA.DEBIT_TAX_CLASS_NO",
        "TRN_JOURNAL_ENTRY_DATA.DEBIT_TAX_RATE_NO",
        "TRN_JOURNAL_ENTRY_DATA.CREDIT_DEPARTMENT_NO",
        "TRN_JOURNAL_ENTRY_DATA.CREDIT_ACCOUNT_NO",
        "TRN_JOURNAL_ENTRY_DATA.CREDIT_SUB_ACCOUNT_NO",
        "TRN_JOURNAL_ENTRY_DATA.CREDIT_SUPPLIER_NO",
        "TRN_JOURNAL_ENTRY_DATA.CREDIT_AMMOUNT",
        "TRN_JOURNAL_ENTRY_DATA.CREDIT_TAX_CLASS_NO",
        "TRN_JOURNAL_ENTRY_DATA.CREDIT_TAX_RATE_NO",
        "TRN_JOURNAL_ENTRY_DATA.ABSTRACT",
        "TRN_JOURNAL_ENTRY_DATA.ROW_NO",
        "TRN_JOURNAL_ENTRY_DATA.EXCEL_ROW_NO",
        "TRN_JOURNAL_ENTRY_DATA.CREATE_DATE",
        "TRN_JOURNAL_ENTRY_HISTORY.CAPTURE_CATEGORY_NO"
      ).map do |values|
        Row.new(
          journal_entry_history_no: values[0],
          company_no: values[1],
          date: values[2],
          department_no: values[3],
          debit_department_no: values[4],
          debit_account_no: values[5],
          debit_sub_account_no: values[6],
          debit_supplier_no: values[7],
          debit_amount: values[8],
          debit_tax_class_no: values[9],
          debit_tax_rate_no: values[10],
          credit_department_no: values[11],
          credit_account_no: values[12],
          credit_sub_account_no: values[13],
          credit_supplier_no: values[14],
          credit_amount: values[15],
          credit_tax_class_no: values[16],
          credit_tax_rate_no: values[17],
          abstract: values[18],
          row_no: values[19],
          excel_row_no: values[20],
          create_date: values[21],
          capture_category_no: values[22]
        )
      end
    end

    def build_company_files(rows)
      grouped = rows.group_by(&:company_no)
      company_names = Company.where(COMPANY_NO: grouped.keys).pluck(:COMPANY_NO, :COMPANY_NAME).to_h
      today_stamp = Time.zone.today.strftime("%Y%m%d")

      grouped.map do |company_no, company_rows|
        file_name = "#{company_names[company_no] || company_no}_#{today_stamp}.csv"
        [file_name, build_company_csv(company_rows)]
      end
    end

    def build_company_csv(rows)
      lines = [HEADER]
      section = "*"
      last_date = nil
      last_row_no = nil
      row_counter = 0

      rows.each_with_index do |row, index|
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
            other.create_date > row.create_date &&
              other.excel_row_no == row.excel_row_no &&
              other.row_no == row.row_no
          end
          if row_counter + same_excel_count >= 250
            section = "*"
            row_counter = 0
          end
        end

        debit_text = [
          row.debit_department_no,
          row.debit_account_no,
          row.debit_sub_account_no,
          2,
          row.debit_supplier_no,
          row.debit_amount,
          row.debit_tax_class_no,
          row.debit_tax_rate_no
        ].map { |value| value.to_s }

        credit_text = [
          row.credit_department_no,
          row.credit_account_no,
          row.credit_sub_account_no,
          2,
          row.credit_supplier_no,
          row.credit_amount,
          row.credit_tax_class_no,
          row.credit_tax_rate_no
        ].map { |value| value.to_s }

        line = ([section, formatted_date] + debit_text + credit_text + [row.abstract.to_s]).join(",")
        lines << line
        section = ""
        row_counter += 1
      end

      UTF8_BOM + lines.join("\n") + "\n"
    end

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

    def mark_histories_executed(history_numbers)
      return if history_numbers.blank?

      TrnJournalEntryHistory.where("JOURNAL_ENTRY_HISTORY_NO IN (?)", history_numbers)
                             .update_all("EXECUTE_FLG" => true)
    end

    def requires_additional_split?(row)
      [LOGISTICS_CATEGORY, LABOR_COST_CATEGORY].include?(row.capture_category_no.to_i)
    end

    def format_date(value)
      return value.to_s unless value.respond_to?(:strftime)

      value.strftime("%Y/%m/%d")
    end
  end
end
