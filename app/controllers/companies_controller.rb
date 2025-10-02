# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :require_login!

  def index
    @companies = Company.order(:company_no)
  end
end
