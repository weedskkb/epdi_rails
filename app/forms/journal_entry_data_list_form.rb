# frozen_string_literal: true

class JournalEntryDataListForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :payment_month, :string
  attribute :supplier, :integer, default: 0
  attribute :except_already_output, :boolean, default: true
  attribute :fund_transfer_date, :string
  attribute :user

  validates :payment_month, presence: true
  validate :validate_payment_month_format
  validate :validate_supplier_for_display, on: :display

  def payment_month_date
    return if payment_month.blank?

    Date.strptime(payment_month, "%Y-%m")
  rescue ArgumentError
    nil
  end

  def supplier_options
    CaptureCategory.active.order(:CAPTURE_CATEGORY_NO).map do |category|
      [
        format("%02d %s", category.capture_category_no, category.capture_category_name),
        category.capture_category_no
      ]
    end
  end

  def except_already_output?
    ActiveModel::Type::Boolean.new.cast(except_already_output)
  end

  def supplier_all?
    supplier.to_i.zero?
  end

  def attributes_for_finder
    {
      payment_month_date: payment_month_date,
      supplier: supplier_all? ? nil : supplier,
      except_already_output: except_already_output?
    }
  end

  private

  def validate_payment_month_format
    return if payment_month.blank?

    Date.strptime(payment_month, "%Y-%m")
  rescue ArgumentError
    errors.add(:payment_month, "支払月はYYYY-MM形式で入力してください。")
  end

  def validate_supplier_for_display
    errors.add(:supplier, "参照時は全件は選択できません。") if supplier_all?
  end
end
