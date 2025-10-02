# frozen_string_literal: true

class CaptureCategoriesController < ApplicationController
  before_action :require_login!

  def index
    @capture_categories = CaptureCategory.order(:capture_category_no)
  end
end
