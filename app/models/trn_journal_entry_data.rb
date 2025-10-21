# frozen_string_literal: true

class TrnJournalEntryData < ApplicationRecord
  self.table_name = "TRN_JOURNAL_ENTRY_DATA"
  self.primary_key = "JOURNAL_ENTRY_DATA_NO"

  alias_attribute :journal_entry_data_no, "JOURNAL_ENTRY_DATA_NO"
  alias_attribute :journal_entry_history_no, "JOURNAL_ENTRY_HISTORY_NO"
  alias_attribute :row_no, "ROW_NO"
  alias_attribute :company_no, "COMPANY_NO"
  alias_attribute :date, "DATE"
  alias_attribute :excel_row_no, "EXCEL_ROW_NO"
  alias_attribute :debit_department_no, "DEBIT_DEPARTMENT_NO"
  alias_attribute :debit_account_no, "DEBIT_ACCOUNT_NO"
  alias_attribute :debit_sub_account_no, "DEBIT_SUB_ACCOUNT_NO"
  alias_attribute :debit_tax_rate_no, "DEBIT_TAX_RATE_NO"
  alias_attribute :debit_tax_class_no, "DEBIT_TAX_CLASS_NO"
  alias_attribute :debit_amount, "DEBIT_AMMOUNT"
  alias_attribute :credit_department_no, "CREDIT_DEPARTMENT_NO"
  alias_attribute :credit_account_no, "CREDIT_ACCOUNT_NO"
  alias_attribute :credit_sub_account_no, "CREDIT_SUB_ACCOUNT_NO"
  alias_attribute :credit_tax_rate_no, "CREDIT_TAX_RATE_NO"
  alias_attribute :credit_tax_class_no, "CREDIT_TAX_CLASS_NO"
  alias_attribute :credit_amount, "CREDIT_AMMOUNT"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :department_no, "DEPARTMENT_NO"
  alias_attribute :abstract, "ABSTRACT"

  belongs_to :journal_entry_history, class_name: "TrnJournalEntryHistory", foreign_key: "JOURNAL_ENTRY_HISTORY_NO", optional: true
end
