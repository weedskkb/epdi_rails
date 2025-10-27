# frozen_string_literal: true

class JournalEntryPattern < ApplicationRecord
  scope :ordered, -> { order(:group_no, :row_no) }

  belongs_to :company, class_name: "Company", foreign_key: :company_id, optional: true
  belongs_to :debit_department, class_name: "Department", foreign_key: :debit_department_id, optional: true
  belongs_to :credit_department, class_name: "Department", foreign_key: :credit_department_id, optional: true
  belongs_to :debit_supplier, class_name: "Supplier", foreign_key: :debit_supplier_id, optional: true
  belongs_to :debit_tax_rate, class_name: "TaxRate", foreign_key: :debit_tax_rate_id, optional: true
  belongs_to :debit_tax_class, class_name: "TaxClass", foreign_key: :debit_tax_class_id, optional: true
  belongs_to :credit_supplier, class_name: "Supplier", foreign_key: :credit_supplier_id, optional: true
  belongs_to :credit_tax_rate, class_name: "TaxRate", foreign_key: :credit_tax_rate_id, optional: true
  belongs_to :credit_tax_class, class_name: "TaxClass", foreign_key: :credit_tax_class_id, optional: true
end
