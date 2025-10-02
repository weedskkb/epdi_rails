# frozen_string_literal: true

class CapturePaymentDataViewModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :target_month, :string
  attribute :capture_category_id, :integer
  attribute :accrual_month, :string
  attribute :payment_month, :string
  attribute :overwrite, :boolean, default: false
  attribute :file
  attribute :user

  validates :target_month, presence: true
  validates :capture_category_id, presence: true
  validate  :file_presence

  def capture_category_options
    CaptureCategory.active.order(:CAPTURE_CATEGORY_NO).pluck(:CAPTURE_CATEGORY_NAME, :CAPTURE_CATEGORY_NO)
  end

  private

  def file_presence
    errors.add(:file, "ファイルを選択してください") if file.blank?
  end
end
