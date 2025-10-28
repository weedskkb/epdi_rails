# frozen_string_literal: true

module JournalEntryData
  class Finder
    PreviewItem = Struct.new(
      :company_id,
      :date,
      :debit_department_id,
      :debit_account_code,
      :debit_account_sub_code,
      :debit_business_connection_code,
      :debit_amount,
      :credit_department_id,
      :credit_account_code,
      :credit_account_sub_code,
      :credit_business_connection_code,
      :credit_amount,
      :abstract,
      keyword_init: true
    )

    def initialize(current_user:, params: {}, form: nil)
      @current_user = current_user
      @params = params
      @form = form
    end

    # JournalEntryDataListApplication::GenerateItemViewModel()
    def relation
      records_table = TrnJournalEntryRecord.table_name
      histories_table = TrnJournalEntryHistory.table_name

      scope = TrnJournalEntryRecord.joins(:journal_entry_history)
      scope = scope.where("#{histories_table}.payment_month = ?", payment_month) if payment_month.present?
      scope = scope.where("#{histories_table}.capture_category_id = ?", supplier) if supplier.present?
      scope = scope.where("#{histories_table}.execute_flag = ?", false) if except_already_output?

      scope.order(<<~SQL.squish)
        #{histories_table}.id ASC,
        #{records_table}.row_no ASC,
        #{records_table}.department_id ASC,
        #{records_table}.created_at ASC
      SQL
    end

    def all
      relation
    end

    # JournalEntryDataListApplication::GenerateItemViewModel()
    def preview_items
      relation.includes(:journal_entry_history).map do |record|
        PreviewItem.new(
          company_id: record.company_id,
          date: record.date,
          debit_department_id: record.debit_department_id,
          debit_account_code: record.debit_account_code,
          debit_account_sub_code: record.debit_account_sub_code,
          debit_business_connection_code: record.debit_business_connection_code,
          debit_amount: record.debit_amount,
          credit_department_id: record.credit_department_id,
          credit_account_code: record.credit_account_code,
          credit_account_sub_code: record.credit_account_sub_code,
          credit_business_connection_code: record.credit_business_connection_code,
          credit_amount: record.credit_amount,
          abstract: record.abstract
        )
      end
    end

    private

    attr_reader :current_user, :params, :form

    def payment_month
      if form&.payment_month_date.present?
        form.payment_month_date
      elsif params[:payment_month].present?
        parse_month(params[:payment_month])
      end
    end

    # JournalEntryDataListApplication::GenerateItemViewModel()
    def supplier
      if form&.supplier_all? == false
        form.supplier
      elsif params[:supplier].present?
        value = params[:supplier].to_i
        value.positive? ? value : nil
      end
    end

    # JournalEntryDataListApplication::GenerateItemViewModel()
    def except_already_output?
      if form
        form.except_already_output?
      else
        ActiveModel::Type::Boolean.new.cast(params[:except_already_output])
      end
    end

    # JournalEntryDataListApplication::GenerateItemViewModel()
    def parse_month(value)
      return if value.blank?

      Date.strptime(value, "%Y-%m")
    rescue ArgumentError
      nil
    end

  end
end
