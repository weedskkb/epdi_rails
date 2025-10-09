# frozen_string_literal: true

module JournalEntryData
  class Finder
    PreviewItem = Struct.new(
      :company_no,
      :date,
      :debit_department_no,
      :debit_account_no,
      :debit_sub_account_no,
      :debit_supplier_no,
      :debit_amount,
      :credit_department_no,
      :credit_account_no,
      :credit_sub_account_no,
      :credit_supplier_no,
      :credit_amount,
      :abstract,
      keyword_init: true
    )

    def initialize(current_user:, params: {}, form: nil)
      @current_user = current_user
      @params = params
      @form = form
    end

    def relation
      scope = TrnJournalEntryData.joins(:journal_entry_history)
      scope = scope.where("TRN_JOURNAL_ENTRY_HISTORY.PAYMENT_MONTH = ?", payment_month) if payment_month.present?
      scope = scope.where("TRN_JOURNAL_ENTRY_HISTORY.CAPTURE_CATEGORY_NO = ?", supplier) if supplier.present?
      scope = scope.where("TRN_JOURNAL_ENTRY_HISTORY.EXECUTE_FLG = ?", false) if except_already_output?

      scope.order(<<~SQL.squish)
        TRN_JOURNAL_ENTRY_HISTORY.JOURNAL_ENTRY_HISTORY_NO ASC,
        TRN_JOURNAL_ENTRY_DATA.ROW_NO ASC,
        TRN_JOURNAL_ENTRY_DATA.DEPARTMENT_NO ASC,
        TRN_JOURNAL_ENTRY_DATA.CREATE_DATE ASC
      SQL
    end

    def all
      relation
    end

    def preview_items
      relation.includes(:journal_entry_history).map do |record|
        PreviewItem.new(
          company_no: record.company_no,
          date: record.date,
          debit_department_no: record.debit_department_no,
          debit_account_no: record.debit_account_no,
          debit_sub_account_no: record.debit_sub_account_no,
          debit_supplier_no: record.debit_supplier_no,
          debit_amount: record.debit_amount,
          credit_department_no: record.credit_department_no,
          credit_account_no: record.credit_account_no,
          credit_sub_account_no: record.credit_sub_account_no,
          credit_supplier_no: record.credit_supplier_no,
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

    def supplier
      if form&.supplier_all? == false
        form.supplier
      elsif params[:supplier].present?
        value = params[:supplier].to_i
        value.positive? ? value : nil
      end
    end

    def except_already_output?
      if form
        form.except_already_output?
      else
        ActiveModel::Type::Boolean.new.cast(params[:except_already_output])
      end
    end

    def parse_month(value)
      return if value.blank?

      Date.strptime(value, "%Y-%m")
    rescue ArgumentError
      nil
    end
  end
end
