# frozen_string_literal: true

class JournalEntryPatternsController < ApplicationController
  before_action :require_login!
  before_action :set_pattern, only: [:edit, :update]
  before_action :set_reference_options, only: [:edit, :update]

  def index
    @patterns = base_query.order(:journal_entry_pattern_no)
  end

  def edit; end

  def update
    if @pattern.update(pattern_params)
      redirect_to journal_entry_patterns_path, notice: "仕訳パターンを更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def base_query
    JournalEntryPattern.includes(
      :company,
      :debit_department,
      :debit_account,
      :debit_sub_account,
      :debit_supplier,
      :debit_tax_class,
      :credit_department,
      :credit_account,
      :credit_sub_account,
      :credit_supplier,
      :credit_tax_class,
      :detail_division
    )
  end

  def set_pattern
    @pattern = base_query.find(params[:id])
  end

  def pattern_params
    params.require(:journal_entry_pattern).permit(
      :journal_entry_pattern_name,
      :journal_entry_pattern_group_no,
      :row_no,
      :date_pattern_no,
      :company_no,
      :debit_department_no,
      :debit_account_no,
      :debit_sub_account_no,
      :debit_supplier_no,
      :debit_tax_rate,
      :debit_tax_class_no,
      :credit_department_no,
      :credit_account_no,
      :credit_sub_account_no,
      :credit_supplier_no,
      :credit_tax_rate,
      :credit_tax_class_no,
      :fixed_amount_flag,
      :fixed_amount,
      :filter_ratio_flag,
      :filter_ratio,
      :filter_amount_flag,
      :filter_amount,
      :detail_division_no,
      :include_tax_flag,
      :tax_calc_flag,
      :accure_flag,
      :delete_flg,
      :abstract
    )
  end

  def set_reference_options
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

    @supplier_options = Supplier.active.order(:supplier_no).map do |supplier|
      ["#{supplier.supplier_no} #{supplier.supplier_name}", supplier.supplier_no]
    end

    @tax_class_options = TaxClass.active.order(:tax_class_no).map do |tax_class|
      ["#{tax_class.tax_class_no} #{tax_class.tax_class_name}", tax_class.tax_class_no]
    end

    @detail_division_options = DetailDivision.active.order(:detail_division_no).map do |division|
      ["#{division.detail_division_no} #{division.detail_division_name}", division.detail_division_no]
    end
  end
end
