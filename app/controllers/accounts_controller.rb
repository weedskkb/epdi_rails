# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :require_login!

  def index
    @accounts = Account.includes(:sub_accounts).order(:account_no)
  end
end
