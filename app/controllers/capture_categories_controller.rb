# frozen_string_literal: true

class CaptureCategoriesController < ApplicationController
  before_action :require_login!

  def index
    @capture_categories = CaptureCategory
                            .includes(
                              :tax_class,
                              :supplier,
                              :supplier_company,
                              :debit_department,
                              :debit_account,
                              :debit_sub_account,
                              :credit_department,
                              :credit_account,
                              :credit_sub_account
                            )
                            .order(:capture_category_no)
  end
end
