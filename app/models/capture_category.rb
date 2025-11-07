# frozen_string_literal: true
class CaptureCategory < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }

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
  enum :tax_rate_code, { tax_rate_8: 8, tax_rate_10: 10 }, prefix: :tax_rate

  def name_with_code
    code = id ? format('%02d', id) : "--"
    "#{code} #{name}"
  end

  def tax_rate_display
    key = tax_rate_code
    return "-" if key.blank?

    I18n.t(
      "activerecord.attributes.capture_category.tax_rate_code.#{key}",
      default: key.to_s.humanize
    )
  end
end
