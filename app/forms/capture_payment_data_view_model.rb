# frozen_string_literal: true

class CapturePaymentDataViewModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :capture_category_id, :integer
  attribute :accrual_month, :string
  attribute :payment_month, :string
  attribute :overwrite, :boolean, default: false
  attribute :file
  attribute :user

  validates :capture_category_id, presence: true
  validate  :file_presence

  attr_accessor :store_data_capture_history,
                :fixed_data_capture_history,
                :whole_data_capture_history,
                :share_data_capture_history,
                :capture_payment_data_item_view_models

  alias overwrite? overwrite

  def initialize(*args)
    super
    self.store_data_capture_history ||= []
    self.fixed_data_capture_history ||= []
    self.whole_data_capture_history ||= []
    self.share_data_capture_history ||= []
    self.capture_payment_data_item_view_models ||= []
  end

  def capture_category_options
    CaptureCategory.active.order(:id).map do |cc|
      [cc.name_with_code, cc.id.to_s]
    end
  end
  def capture_category
    capture_category_id.to_i if capture_category_id.present?
  end

  private

  def file_presence
    errors.add(:file, "ファイルまたはフォルダを選択してください") if file.blank?
  end
end
