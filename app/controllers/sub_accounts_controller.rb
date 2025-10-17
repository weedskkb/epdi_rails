# frozen_string_literal: true

class SubAccountsController < ApplicationController
  before_action :require_login!

  def index
    @sub_accounts = SubAccount.includes(:account).order(:account_no, :sub_account_no)
  end
end
