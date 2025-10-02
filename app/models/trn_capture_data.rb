# frozen_string_literal: true

class TrnCaptureData < ApplicationRecord
  self.table_name = "TRN_CAPTURE_DATA"
  self.primary_key = "CAPTURE_DATA_NO"

  alias_attribute :capture_data_no, "CAPTURE_DATA_NO"
  alias_attribute :capture_history_no, "CAPTURE_HISTORY_NO"
  alias_attribute :row_no, "ROW_NO"
  alias_attribute :company_no, "COMPANY_NO"
  alias_attribute :department_no, "DEPARTMENT_NO"
  alias_attribute :supplier_no, "SUPPLIER_NO"
  alias_attribute :account_no, "ACCOUNT_NO"
  alias_attribute :sub_account_no, "SUB_ACCOUNT_NO"
  alias_attribute :amount, "AMMOUNT"
  alias_attribute :second_amount, "SECOND_AMMOUNT"
  alias_attribute :tax_class_no, "TAX_CLASS_NO"
  alias_attribute :tax_rate_no, "TAX_RATE_NO"
  alias_attribute :detail_division_no, "DETAIL_DIVISION_NO"
  alias_attribute :summary, "SUMMARY"
  alias_attribute :journal_entry_pattern_no, "JOURNAL_ENTRY_PATTERN_NO"
  alias_attribute :error_flg, "ERROR_FLG"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :update_date, "UPDATE_DATE"
  alias_attribute :update_user_id, "UPDATE_USER_ID"

  belongs_to :capture_history, class_name: "TrnCaptureHistory", foreign_key: "CAPTURE_HISTORY_NO"
  belongs_to :department, class_name: "Department", foreign_key: "DEPARTMENT_NO"
  belongs_to :company, class_name: "Company", foreign_key: "COMPANY_NO"
end
