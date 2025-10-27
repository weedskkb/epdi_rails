# frozen_string_literal: true
class CaptureCategory < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }

  belongs_to :tax_class, class_name: "TaxClass", optional: true
  belongs_to :tax_rate, class_name: "TaxRate", optional: true
  belongs_to :supplier, class_name: "Supplier", optional: true
  belongs_to :supplier_company, class_name: "Company", optional: true
  belongs_to :debit_department, class_name: "Department", optional: true
  belongs_to :credit_department, class_name: "Department", optional: true

  def name_with_code
    code = id ? format('%02d', id) : "--"
    "#{code} #{name}"
  end

  def tax_rate_display
    tax_rate&.rate
  end
end
