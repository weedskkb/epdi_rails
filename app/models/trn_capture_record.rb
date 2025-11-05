# frozen_string_literal: true

class TrnCaptureRecord < ApplicationRecord
  belongs_to :capture_history, class_name: "TrnCaptureHistory", inverse_of: :capture_records
  belongs_to :department, class_name: "Department", foreign_key: :department_code, primary_key: :code, optional: true
  belongs_to :tax_rate, class_name: "TaxRate", foreign_key: :tax_rate_id, optional: true
  belongs_to :company, class_name: "Company", foreign_key: :company_code, primary_key: :code, optional: true
  belongs_to :business_connection,
             class_name: "BusinessConnection",
             foreign_key: :business_connection_code,
             primary_key: :code,
             optional: true

  enum :tax_class_code, { standard: 0, reduced: 1 }, prefix: :tax_class

  delegate :capture_category, to: :capture_history, allow_nil: true

  def summary
    template = capture_category&.abstract
    return nil if template.blank?

    text = template.dup
    text.gsub!("発生月", formatted_month(capture_history&.accrual_month || capture_history&.payment_month)) if text.include?("発生月")
    text.gsub!("支払月", formatted_month(capture_history&.payment_month)) if text.include?("支払月")
    text.gsub!("店舗名", department&.name.to_s) if text.include?("店舗名")
    text.gsub!("会社名", company&.name.to_s) if text.include?("会社名")
    text.gsub!("仕入先別", capture_category&.supplier_abstract.to_s) if text.include?("仕入先別")
    text
  end

  private

  def formatted_month(value)
    return "" if value.blank?

    date =
      case value
      when Date
        value
      when Time, DateTime
        value.to_date
      else
        Date.parse(value.to_s)
      end

    date.strftime("%-m月")
  rescue ArgumentError, TypeError
    value.to_s
  end

end
