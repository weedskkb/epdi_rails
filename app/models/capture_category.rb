# frozen_string_literal: true

class CaptureCategory < ApplicationRecord
  self.table_name = "MST_CAPTURE_CATEGORY"
  self.primary_key = "CAPTURE_CATEGORY_NO"

  alias_attribute :capture_category_no, "CAPTURE_CATEGORY_NO"
  alias_attribute :capture_category_name, "CAPTURE_CATEGORY_NAME"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :journal_entry_pattern_group_no, "JOURNAL_ENTRY_PATTERN_GROUP_NO"
  alias_attribute :debit_account_no, "DEBIT_ACCOUNT_NO"
  alias_attribute :debit_sub_account_no, "DEBIT_SUB_ACCOUNT_NO"
  alias_attribute :credit_account_no, "CREDIT_ACCOUNT_NO"
  alias_attribute :credit_sub_account_no, "CREDIT_SUB_ACCOUNT_NO"
  alias_attribute :abstract, "ABSTRACT"
  alias_attribute :supplier_abstract, "SUPPLIER_ABSTRACT"
  alias_attribute :payment_terms, "PAYMENT_TERMS"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :update_user_id, "UPDATE_USER_ID"
  alias_attribute :update_date, "UPDATE_DATE"

  scope :active, -> { where(DELETE_FLG: false) }

  belongs_to :tax_class, class_name: "TaxClass", foreign_key: :tax_class_id, optional: true
  belongs_to :tax_rate, class_name: "TaxRate", foreign_key: :tax_rate_id, optional: true
  belongs_to :supplier, class_name: "Supplier", foreign_key: :supplier_id, optional: true
  belongs_to :supplier_company, class_name: "Company", foreign_key: :supplier_company_id, optional: true
  belongs_to :debit_department, class_name: "Department", foreign_key: :debit_department_id, optional: true
  belongs_to :debit_account, class_name: "Account", foreign_key: "DEBIT_ACCOUNT_NO", optional: true
  belongs_to :debit_sub_account, class_name: "SubAccount", foreign_key: "DEBIT_SUB_ACCOUNT_NO",
                                  primary_key: "SUB_ACCOUNT_NO", optional: true
  belongs_to :credit_department, class_name: "Department", foreign_key: :credit_department_id, optional: true
  belongs_to :credit_account, class_name: "Account", foreign_key: "CREDIT_ACCOUNT_NO", optional: true
  belongs_to :credit_sub_account, class_name: "SubAccount", foreign_key: "CREDIT_SUB_ACCOUNT_NO",
                                  primary_key: "SUB_ACCOUNT_NO", optional: true

  def name_with_code
    capture_category_no.to_s + ' ' + capture_category_name
  end

  def tax_rate_display
    tax_rate&.rate
  end
end
