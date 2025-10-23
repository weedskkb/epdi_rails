# frozen_string_literal: true

class DepartmentsController < ApplicationController
  before_action :require_login!

  def index
    @departments = Department.order(:id)
  end
end
