# frozen_string_literal: true

class SuppliersController < ApplicationController
  before_action :require_login!

  def index
    @suppliers = Supplier.order(:id)
  end
end
