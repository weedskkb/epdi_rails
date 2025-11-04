# frozen_string_literal: true

class AccountingItemsController < ApplicationController
  before_action :require_login!

  def index
    @accounting_items = AccountingItem.includes(:company).order(:code, :sub_code)
  end
end
