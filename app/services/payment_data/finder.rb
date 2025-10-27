# frozen_string_literal: true

module PaymentData
  class Finder
    def initialize(current_user:, params: {})
      @current_user = current_user
      @params = params
    end

    def all
      scope = TrnCaptureRecord.includes(:department, :company, :tax_class, :tax_rate, capture_history: :capture_category)
      company_filter = params[:company_id].presence || params[:company_no].presence
      scope = scope.where(company_id: company_filter) if company_filter.present?
      scope.order(:capture_history_id, :row_no)
    end

    private

    attr_reader :current_user, :params
  end
end
