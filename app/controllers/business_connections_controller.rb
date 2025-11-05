# frozen_string_literal: true

class BusinessConnectionsController < ApplicationController
  before_action :require_login!

  def index
    @business_connections = BusinessConnection.order(:code)
  end
end
