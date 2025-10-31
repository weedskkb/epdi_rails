# frozen_string_literal: true

class DepartmentsController < ApplicationController
  before_action :require_login!

  def index
    # @departments = BsDepartment.order(:id)
    @departments = Department.order(Arel.sql("(code REGEXP '^[0-9]+$') DESC, CAST(code AS UNSIGNED)"))
  end
end
