# frozen_string_literal: true

class TrnJournalEntryRecord < ApplicationRecord
  belongs_to :journal_entry_history, class_name: "TrnJournalEntryHistory", inverse_of: :journal_entry_records
  belongs_to :company, class_name: "Company", foreign_key: :company_code, primary_key: :code, optional: true
  belongs_to :department, class_name: "Department", foreign_key: :department_code, primary_key: :code, optional: true
  belongs_to :debit_department, class_name: "Department", foreign_key: :debit_department_code, primary_key: :code, optional: true
  belongs_to :credit_department, class_name: "Department", foreign_key: :credit_department_code, primary_key: :code, optional: true
  belongs_to :debit_business_connection,
             class_name: "BusinessConnection",
             foreign_key: :debit_business_connection_code,
             primary_key: :code,
             optional: true
  belongs_to :credit_business_connection,
             class_name: "BusinessConnection",
             foreign_key: :credit_business_connection_code,
             primary_key: :code,
             optional: true

  enum :debit_tax_class_code, { standard: 0, reduced: 1 }, prefix: :debit_tax_class
  enum :credit_tax_class_code, { standard: 0, reduced: 1 }, prefix: :credit_tax_class
  enum :debit_tax_rate_code, { tax_rate_8: 8, tax_rate_10: 10 }, prefix: :debit_tax_rate
  enum :credit_tax_rate_code, { tax_rate_8: 8, tax_rate_10: 10 }, prefix: :credit_tax_rate

end
