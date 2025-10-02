# frozen_string_literal: true

module JournalEntryData
  class Finder
    def initialize(current_user:, params: {})
      @current_user = current_user
      @params = params
    end

    def all
      scope = TrnJournalEntryData.all
      scope = scope.where(CAPTURE_HISTORY_NO: params[:capture_history_no]) if params[:capture_history_no].present?
      scope.order(:CAPTURE_HISTORY_NO, :ROW_NO)
    end

    private

    attr_reader :current_user, :params
  end
end
