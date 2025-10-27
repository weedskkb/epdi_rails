# frozen_string_literal: true

class CaptureCategoriesController < ApplicationController
  before_action :require_login!
  before_action :set_capture_category, only: [:edit, :update]
  before_action :set_reference_options, only: [:edit, :update]

  def index
    @capture_categories = CaptureCategory
                            .includes(
                              :tax_class,
                              :tax_rate,
                              :supplier,
                              :supplier_company,
                              :debit_department,
                              :credit_department
                            )
                            .order(:id)
  end

  def edit; end

  def update
    if @capture_category.update(capture_category_params)
      redirect_to capture_categories_path, notice: "取込区分を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_capture_category
    @capture_category = CaptureCategory.find(params[:id])
  end

  def capture_category_params
    params.require(:capture_category).permit(
      :name,
      :tax_class_id,
      :tax_rate_id,
      :supplier_id,
      :supplier_company_id,
      :debit_department_id,
      :debit_account_code,
      :debit_account_sub_code,
      :credit_department_id,
      :credit_account_code,
      :credit_account_sub_code,
      :abstract,
      :supplier_abstract,
      :journal_entry_pattern_group_no,
      :payment_terms,
      :delete_flg
    )
  end

  def set_reference_options
    @tax_class_options = TaxClass.active.order(:id).map do |tax_class|
      ["#{tax_class.id} #{tax_class.name}", tax_class.id]
    end

    @tax_rate_options = TaxRate.active.order(:id).map do |tax_rate|
      ["#{tax_rate.id} => #{tax_rate.rate}%", tax_rate.id]
    end

    @supplier_options = Supplier.active.order(:id).map do |supplier|
      ["#{supplier.id} #{supplier.name}", supplier.id]
    end

    @company_options = Company.active.order(:id).map do |company|
      ["#{company.id} #{company.name}", company.id]
    end

    @department_options = Department.active.order(:id).map do |department|
      ["#{department.id} #{department.department_name}", department.id]
    end

    @account_options = Account.active.order(:code).map do |account|
      ["#{account.code} #{account.name}", account.code]
    end

    @journal_entry_pattern_group_options = JournalEntryPattern
                                            .select(:group_no, :name)
                                            .distinct
                                            .order(:group_no)
                                            .map do |pattern|
      ["#{pattern.group_no} #{pattern.name}", pattern.group_no]
    end
  end
end
