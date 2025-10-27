# frozen_string_literal: true

class CapturePaymentDataViewModelPresenter
  HistoryItem = Struct.new(:capture_date, :capture_category_id, :capture_category_label, :accrual_month, :payment_month, keyword_init: true) do
    def capture_category_no
      capture_category_id
    end

    def capture_category
      capture_category_label
    end
  end

  def self.build(current_user, view_model = CapturePaymentDataViewModel.new)
    new(current_user).build(view_model)
  end

  def initialize(current_user)
    @current_user = current_user
  end

  def build(view_model)
    view_model.user ||= current_user
    view_model.target_month ||= current_month
    assign_histories(view_model)
    view_model
  end

  private

  attr_reader :current_user

  def assign_histories(view_model)
    items = recent_histories.map do |history|
      category = history.capture_category
      HistoryItem.new(
        capture_date: history.created_at&.strftime('%Y/%m/%d'),
        capture_category_id: category.id,
        capture_category_label: format('%02d：%s', category.id, category.name),
        accrual_month: normalize_month(history.accrual_month),
        payment_month: normalize_month(history.payment_month)
      )
    end

    view_model.capture_payment_data_item_view_models = items
    view_model.store_data_capture_history = items.select { |item| item.capture_category_id == 16 }
    view_model.fixed_data_capture_history = items.select { |item| item.capture_category_id == 24 }
    view_model.whole_data_capture_history = items.select { |item| item.capture_category_id == 1 }
    view_model.share_data_capture_history = items.reject { |item| [16, 24, 1].include?(item.capture_category_id) }
  end

  def recent_histories
    to_time = Time.zone.now
    from_time = to_time - 2.months
    TrnCaptureHistory
      .includes(:capture_category)
      .where(created_at: from_time..to_time)
      .order(created_at: :desc)
  end

  def current_month
    Time.zone.today.strftime('%Y-%m')
  end

  def normalize_month(value)
    value.to_s.tr('-', '/') if value.present?
  end
end
