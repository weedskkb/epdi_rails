# frozen_string_literal: true

class CapturePaymentDataViewModelPresenter
  def self.build(current_user)
    new(current_user).to_view_model
  end

  def initialize(current_user)
    @current_user = current_user
  end

  def to_view_model
    CapturePaymentDataViewModel.new(
      target_month: current_month,
      user: current_user
    )
  end

  private

  attr_reader :current_user

  def current_month
    Time.zone.today.strftime("%Y-%m")
  end
end
