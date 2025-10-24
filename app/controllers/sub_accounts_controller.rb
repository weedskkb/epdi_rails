# frozen_string_literal: true

class SubAccountsController < ApplicationController
  before_action :require_login!

  def index
    @sub_accounts = SubAccount.includes(:account).order(:code, :sub_code)
  end
end
