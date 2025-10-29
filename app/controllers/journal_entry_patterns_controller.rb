# frozen_string_literal: true

class JournalEntryPatternsController < ApplicationController
  before_action :require_login!
  before_action :set_pattern, only: [:edit, :update]
  before_action :set_reference_options, only: [:edit, :update]

  def index
    @patterns = base_query.order(:id)
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
      :debit_business_connection,
      :debit_tax_rate,
      :debit_tax_class,
      :credit_department,
      :credit_business_connection,
      :credit_tax_rate,
      :credit_tax_class,
    )
  end

  def set_pattern
    @pattern = base_query.find(params[:id])
  end

  def pattern_params
    params.require(:journal_entry_pattern).permit(
      :name,
      :group_no,
      :row_no,
      :date_pattern_no,
      :company_code,
      :debit_department_id,
      :debit_account_code,
      :debit_account_sub_code,
      :debit_business_connection_code,
      :debit_tax_rate_id,
      :debit_tax_class_id,
      :credit_department_id,
      :credit_account_code,
      :credit_account_sub_code,
      :credit_business_connection_code,
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
    @company_options = Company.active.order(:code).map do |company|
      ["#{company.code} #{company.name}", company.code]
    end

    @department_options = Department.active.order(:id).map do |department|
      ["#{department.id} #{department.department_name}", department.id]
    end

    @account_options = Account.active.order(:code).map do |account|
      ["#{account.code} #{account.name}", account.code]
    end

    placeholder_options = [
      ["0 取込データの取引先を使用", "0"],
      ["1 会社の取引先を使用", "1"],
      ["2 取込区分の取引先を使用", "2"]
    ]

    business_connection_choices = BusinessConnection.active.order(:code).map do |connection|
      ["#{connection.code} #{connection.name}", connection.code]
    end

    @business_connection_options = placeholder_options + business_connection_choices

    @tax_class_options = TaxClass.active.order(:id).map do |tax_class|
      ["#{tax_class.id} #{tax_class.name}", tax_class.id]
    end

    @tax_rate_options = TaxRate.active.order(:id).map do |tax_rate|
      ["#{tax_rate.id} => #{tax_rate.rate}%", tax_rate.id]
    end
  end
end
