# frozen_string_literal: true

class CapturePaymentDataController < ApplicationController
  before_action :require_login!

  def index
    @view_model = CapturePaymentDataViewModelPresenter.build(current_user)
  end

  def capture
    @view_model = CapturePaymentDataViewModel.new(capture_params.merge(user: current_user))

    unless @view_model.valid?
      flash.now[:alert] = '入力内容を確認してください'
      @view_model = CapturePaymentDataViewModelPresenter.build(current_user, @view_model)
      render :index, status: :unprocessable_entity
      return
    end
    result = CapturePaymentData::Capture.call(@view_model)
    if result.success?
      redirect_to capture_payment_data_path, success: result.message
    else
      flash.now[:alert] = result.message
      @view_model = CapturePaymentDataViewModelPresenter.build(current_user, @view_model)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def capture_params
    params.require(:capture_payment_data_view_model)
          .permit(:target_month, :capture_category_id, :accrual_month, :payment_month, :overwrite, :file)
  end
end
