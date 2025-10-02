# frozen_string_literal: true

class PaymentDataController < ApplicationController
  before_action :require_login!

  def index
    @payment_data = PaymentData::Finder.new(current_user: current_user, params: params).all
  end
end
