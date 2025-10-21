# frozen_string_literal: true

class CaptureCategoriesController < ApplicationController
  before_action :require_login!
  before_action :set_capture_category, only: [:edit, :update]
  before_action :set_reference_options, only: [:edit, :update]

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
      :capture_category_name,
      :tax_class_no,
      :tax_rate_value,
      :supplier_id,
      :supplier_company_no,
      :debit_department_no,
      :debit_account_no,
      :debit_sub_account_no,
      :credit_department_no,
      :credit_account_no,
      :credit_sub_account_no,
      :abstract,
      :supplier_abstract,
      :journal_entry_pattern_group_no,
      :payment_terms,
      :delete_flg
    )
  end

  def set_reference_options
    @tax_class_options = TaxClass.active.order(:tax_class_no).map do |tax_class|
      ["#{tax_class.tax_class_no} #{tax_class.tax_class_name}", tax_class.tax_class_no]
    end

    @supplier_options = Supplier.active.order(:id).map do |supplier|
      ["#{supplier.id} #{supplier.name}", supplier.id]
    end

    @company_options = Company.active.order(:company_no).map do |company|
      ["#{company.company_no} #{company.company_name}", company.company_no]
    end

    @department_options = Department.active.order(:department_no).map do |department|
      ["#{department.department_no} #{department.department_name}", department.department_no]
    end

    @account_options = Account.active.order(:account_no).map do |account|
      ["#{account.account_no} #{account.account_name}", account.account_no]
    end

    @sub_account_options = SubAccount.active.order(:account_no, :sub_account_no).map do |sub_account|
      ["#{sub_account.sub_account_no} #{sub_account.sub_account_name}", sub_account.sub_account_no]
    end

    @journal_entry_pattern_group_options = JournalEntryPattern
                                            .select(:journal_entry_pattern_group_no, :journal_entry_pattern_name)
                                            .distinct
                                            .order(:journal_entry_pattern_group_no)
                                            .map do |pattern|
      ["#{pattern.journal_entry_pattern_group_no} #{pattern.journal_entry_pattern_name}",
       pattern.journal_entry_pattern_group_no]
    end
  end
end
