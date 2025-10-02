# frozen_string_literal: true

class TrnJournalEntryData < ApplicationRecord
  self.table_name = "TRN_JOURNAL_ENTRY_DATA"
  self.primary_key = "JOURNAL_ENTRY_DATA_NO"

  alias_attribute :journal_entry_data_no, "JOURNAL_ENTRY_DATA_NO"
  alias_attribute :capture_history_no, "CAPTURE_HISTORY_NO"
  alias_attribute :row_no, "ROW_NO"
  alias_attribute :debit_company_no, "DEBIT_COMPANY_NO"
  alias_attribute :debit_department_no, "DEBIT_DEPARTMENT_NO"
  alias_attribute :debit_account_no, "DEBIT_ACCOUNT_NO"
  alias_attribute :debit_sub_account_no, "DEBIT_SUB_ACCOUNT_NO"
  alias_attribute :debit_supplier_no, "DEBIT_SUPPLIER_NO"
  alias_attribute :debit_tax_rate_no, "DEBIT_TAX_RATE_NO"
  alias_attribute :debit_tax_class_no, "DEBIT_TAX_CLASS_NO"
  alias_attribute :credit_company_no, "CREDIT_COMPANY_NO"
  alias_attribute :credit_department_no, "CREDIT_DEPARTMENT_NO"
  alias_attribute :credit_account_no, "CREDIT_ACCOUNT_NO"
  alias_attribute :credit_sub_account_no, "CREDIT_SUB_ACCOUNT_NO"
  alias_attribute :credit_supplier_no, "CREDIT_SUPPLIER_NO"
  alias_attribute :credit_tax_rate_no, "CREDIT_TAX_RATE_NO"
  alias_attribute :credit_tax_class_no, "CREDIT_TAX_CLASS_NO"
  alias_attribute :amount, "AMMOUNT"
  alias_attribute :second_amount, "SECOND_AMMOUNT"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :update_date, "UPDATE_DATE"
  alias_attribute :update_user_id, "UPDATE_USER_ID"
  alias_attribute :department_no, "DEPARTMENT_NO"

  belongs_to :capture_history, class_name: "TrnCaptureHistory", foreign_key: "CAPTURE_HISTORY_NO"
end
