# frozen_string_literal: true

module PaymentData
  class Finder
    def initialize(current_user:, params: {})
      @current_user = current_user
      @params = params
    end

    def all
      scope = TrnCaptureRecord.includes(:department, :company, capture_history: :capture_category)
      company_filter = params[:company_code].presence
      scope = scope.where(company_code: company_filter) if company_filter.present?
      scope.order(:capture_history_id, :row_no)
    end

    private

    attr_reader :current_user, :params
  end
end
