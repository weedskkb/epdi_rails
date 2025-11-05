# frozen_string_literal: true

class BsDepartmentsController < ApplicationController
  before_action :require_login!

  def index
    @bs_departments = BsDepartment.order(:id)
    company_ids = @bs_departments.map(&:company_id).compact.uniq
    @bs_companies_by_id = BsCompany.where(id: company_ids).index_by(&:id)
  end
end
