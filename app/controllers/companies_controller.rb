# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :require_login!

  def index
    @companies = Company.order(:code)
  end
end
