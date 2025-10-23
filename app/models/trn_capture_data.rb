# frozen_string_literal: true

class TrnCaptureData < ApplicationRecord
  self.table_name = "TRN_CAPTURE_DATA"
  self.primary_key = "CAPTURE_DATA_NO"

  alias_attribute :capture_data_no, "CAPTURE_DATA_NO"
  alias_attribute :capture_history_no, "CAPTURE_HISTORY_NO"
  alias_attribute :row_no, "ROW_NO"
  alias_attribute :department_no, "DEPARTMENT_NO"
  alias_attribute :account_no, "ACCOUNT_NO"
  alias_attribute :sub_account_no, "SUB_ACCOUNT_NO"
  alias_attribute :list_cd, "LIST_CD"
  alias_attribute :amount, "AMMOUNT"
  alias_attribute :second_amount, "SECOND_AMMOUNT"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :create_user_id, "CREATE_USER_ID"

  belongs_to :capture_history, class_name: "TrnCaptureHistory", foreign_key: "CAPTURE_HISTORY_NO"
  belongs_to :department, class_name: "Department", foreign_key: "DEPARTMENT_NO"
  belongs_to :tax_class, class_name: "TaxClass", foreign_key: :tax_class_id, optional: true
  belongs_to :tax_rate, class_name: "TaxRate", foreign_key: :tax_rate_id, optional: true
  belongs_to :company, class_name: "Company", foreign_key: :company_id, optional: true

  delegate :capture_category, to: :capture_history, allow_nil: true

  def summary
    template = capture_category&.abstract
    return nil if template.blank?

    text = template.dup
    text.gsub!("発生月", formatted_month(capture_history&.accrual_month || capture_history&.payment_month)) if text.include?("発生月")
    text.gsub!("支払月", formatted_month(capture_history&.payment_month)) if text.include?("支払月")
    text.gsub!("店舗名", department&.department_name.to_s) if text.include?("店舗名")
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
