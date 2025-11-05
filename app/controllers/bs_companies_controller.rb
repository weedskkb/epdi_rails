# frozen_string_literal: true

class BsCompaniesController < ApplicationController
  before_action :require_login!

  def index
    @bs_companies = BsCompany.includes(:business_connection).order(:id)
  end
end
