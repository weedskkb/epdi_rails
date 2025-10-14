# frozen_string_literal: true

module PaymentData
  class Finder
    def initialize(current_user:, params: {})
      @current_user = current_user
      @params = params
    end

    def all
      scope = TrnCaptureData.includes(:department, :company, capture_history: :capture_category)
      scope = scope.where(COMPANY_NO: params[:company_no]) if params[:company_no].present?
      scope.order(:CAPTURE_HISTORY_NO, :ROW_NO)
    end

    private

    attr_reader :current_user, :params
  end
end
