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
      :credit_department,
      :credit_business_connection
    ).order(:group_no, :row_no, :date_pattern_no)
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
      :debit_department_code,
      :debit_account_code,
      :debit_account_sub_code,
      :debit_business_connection_code,
      :debit_tax_rate_code,
      :debit_tax_class_code,
      :credit_department_code,
      :credit_account_code,
      :credit_account_sub_code,
      :credit_business_connection_code,
      :credit_tax_rate_code,
      :credit_tax_class_code,
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

    @department_options = Department.active.order(:code).map do |department|
      ["#{department.code} #{department.name}", department.code]
    end

    @account_options = AccountingItem.root_account_options

    placeholder_options = [
      ["0 取込データの取引先を使用", "0"],
      ["1 会社の取引先を使用", "1"],
      ["2 取込区分の取引先を使用", "2"]
    ]

    business_connection_choices = BusinessConnection.active.order(:code).map do |connection|
      ["#{connection.code} #{connection.name}", connection.code]
    end

    @business_connection_options = placeholder_options + business_connection_choices

    @tax_class_code_options = JournalEntryPattern.debit_tax_class_codes.map do |name, code|
      label = I18n.t(
        "activerecord.attributes.journal_entry_pattern.debit_tax_class_code.#{name}",
        default: name.to_s.humanize
      )
      ["#{code} #{label}", name]
    end

    @tax_rate_options = JournalEntryPattern.debit_tax_rate_codes.map do |name, code|
      label = I18n.t(
        "activerecord.attributes.journal_entry_pattern.debit_tax_rate_code.#{name}",
        default: name.to_s.humanize
      )
      ["#{code} #{label}", name]
    end
  end
end
