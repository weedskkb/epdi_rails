# frozen_string_literal: true

module CapturePaymentData
  class Capture
    def self.call(view_model)
      new(view_model).call
    end

    def initialize(view_model)
      @view_model = view_model
    end

    def call
      return ServiceResult.new(success: false, message: "セッションが無効です。") if view_model.user.blank?

      # TODO: Implement Excel parsing, validation, and persistence logic ported from the .NET CapturePaymentDataApplication.
      ServiceResult.new(success: true, message: "未実装: 取込処理を完了しました (ダミー)")
    rescue StandardError => e
      Rails.logger.error("Capture failed: #{e.class} #{e.message}\n#{e.backtrace.join('\n')}")
      ServiceResult.new(success: false, message: "取込に失敗しました。")
    end

    private

    attr_reader :view_model
  end
end
