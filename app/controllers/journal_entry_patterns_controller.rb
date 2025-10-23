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
      :debit_tax_rate,
      :debit_tax_class,
      :credit_department,
      :credit_account,
      :credit_sub_account,
      :credit_supplier,
      :credit_tax_rate,
      :credit_tax_class,
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
      :company_id,
      :debit_department_id,
      :debit_account_no,
      :debit_sub_account_no,
      :debit_supplier_id,
      :debit_tax_rate_id,
      :debit_tax_class_id,
      :credit_department_id,
      :credit_account_no,
      :credit_sub_account_no,
      :credit_supplier_id,
      :credit_tax_rate_id,
      :credit_tax_class_id,
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
    @company_options = Company.active.order(:id).map do |company|
      ["#{company.id} #{company.name}", company.id]
    end

    @department_options = Department.active.order(:id).map do |department|
      ["#{department.id} #{department.department_name}", department.id]
    end

    @account_options = Account.active.order(:account_no).map do |account|
      ["#{account.account_no} #{account.account_name}", account.account_no]
    end

    @sub_account_options = SubAccount.active.order(:account_no, :sub_account_no).map do |sub_account|
      ["#{sub_account.sub_account_no} #{sub_account.sub_account_name}", sub_account.sub_account_no]
    end

    @supplier_options = Supplier.active.order(:id).map do |supplier|
      ["#{supplier.id} #{supplier.name}", supplier.id]
    end

    @tax_class_options = TaxClass.active.order(:id).map do |tax_class|
      ["#{tax_class.id} #{tax_class.name}", tax_class.id]
    end

    @tax_rate_options = TaxRate.active.order(:id).map do |tax_rate|
      ["#{tax_rate.id} => #{tax_rate.rate}%", tax_rate.id]
    end
  end
end
