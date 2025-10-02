# frozen_string_literal: true

class ServiceResult
  attr_reader :message, :payload

  def initialize(success:, message: nil, payload: nil)
    @success = success
    @message = message
    @payload = payload
  end

  def success?
    @success
  end

  def failure?
    !success?
  end
end
