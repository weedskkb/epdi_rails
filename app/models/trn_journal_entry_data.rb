# frozen_string_literal: true

class TrnJournalEntryData < ApplicationRecord
  self.table_name = "TRN_JOURNAL_ENTRY_DATA"
  self.primary_key = "JOURNAL_ENTRY_DATA_NO"

  alias_attribute :journal_entry_data_no, "JOURNAL_ENTRY_DATA_NO"
  alias_attribute :journal_entry_history_no, "JOURNAL_ENTRY_HISTORY_NO"
  alias_attribute :row_no, "ROW_NO"
  alias_attribute :date, "DATE"
  alias_attribute :excel_row_no, "EXCEL_ROW_NO"
  alias_attribute :debit_amount, "DEBIT_AMMOUNT"
  alias_attribute :credit_amount, "CREDIT_AMMOUNT"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :abstract, "ABSTRACT"

  belongs_to :journal_entry_history, class_name: "TrnJournalEntryHistory", foreign_key: "JOURNAL_ENTRY_HISTORY_NO", optional: true
  belongs_to :company, class_name: "Company", foreign_key: :company_id, optional: true
  belongs_to :debit_tax_rate, class_name: "TaxRate", foreign_key: :debit_tax_rate_id, optional: true
  belongs_to :debit_tax_class, class_name: "TaxClass", foreign_key: :debit_tax_class_id, optional: true
  belongs_to :credit_tax_rate, class_name: "TaxRate", foreign_key: :credit_tax_rate_id, optional: true
  belongs_to :credit_tax_class, class_name: "TaxClass", foreign_key: :credit_tax_class_id, optional: true
end
