# frozen_string_literal: true

class CaptureCategory < ApplicationRecord
  self.table_name = "MST_CAPTURE_CATEGORY"
  self.primary_key = "CAPTURE_CATEGORY_NO"

  alias_attribute :capture_category_no, "CAPTURE_CATEGORY_NO"
  alias_attribute :capture_category_name, "CAPTURE_CATEGORY_NAME"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :journal_entry_pattern_group_no, "JOURNAL_ENTRY_PATTERN_GROUP_NO"
  alias_attribute :tax_class_no, "TAX_CLASS_NO"
  alias_attribute :supplier_no, "SUPPLIER_NO"
  alias_attribute :supplier_company_no, "SUPPLIER_COMPANY_NO"
  alias_attribute :debit_department_no, "DEBIT_DEPARTMENT_NO"
  alias_attribute :debit_account_no, "DEBIT_ACCOUNT_NO"
  alias_attribute :debit_sub_account_no, "DEBIT_SUB_ACCOUNT_NO"
  alias_attribute :credit_department_no, "CREDIT_DEPARTMENT_NO"
  alias_attribute :credit_account_no, "CREDIT_ACCOUNT_NO"
  alias_attribute :credit_sub_account_no, "CREDIT_SUB_ACCOUNT_NO"
  alias_attribute :abstract, "ABSTRACT"
  alias_attribute :supplier_abstract, "SUPPLIER_ABSTRACT"
  alias_attribute :payment_terms, "PAYMENT_TERMS"
  alias_attribute :tax_rate_value, "TAX_RATE"

  scope :active, -> { where(DELETE_FLG: false) }

  belongs_to :tax_class, class_name: "TaxClass", foreign_key: "TAX_CLASS_NO", optional: true

  def name_with_code
    capture_category_no.to_s + ' ' + capture_category_name
  end
end
