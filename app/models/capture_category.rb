# frozen_string_literal: true
class CaptureCategory < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }

  belongs_to :tax_rate, class_name: "TaxRate", optional: true
  belongs_to :business_connection,
             class_name: "BusinessConnection",
             foreign_key: :business_connection_code,
             primary_key: :code,
             optional: true
  belongs_to :business_connection_company,
             class_name: "Company",
             foreign_key: :business_connection_company_code,
             primary_key: :code,
             optional: true
  belongs_to :debit_department,
             class_name: "Department",
             foreign_key: :debit_department_code,
             primary_key: :code,
             optional: true
  belongs_to :credit_department,
             class_name: "Department",
             foreign_key: :credit_department_code,
             primary_key: :code,
             optional: true

  enum :tax_class_code, { standard: 0, reduced: 1 }, prefix: :tax_class

  def name_with_code
    code = id ? format('%02d', id) : "--"
    "#{code} #{name}"
  end

  def tax_rate_display
    tax_rate&.rate
  end
end
