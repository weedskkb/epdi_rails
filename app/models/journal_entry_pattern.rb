# frozen_string_literal: true

class JournalEntryPattern < ApplicationRecord
  self.table_name = "MST_JOURNAL_ENTRY_PATTERN"
  self.primary_key = "JOURNAL_ENTRY_PATTERN_NO"

  alias_attribute :journal_entry_pattern_no, "JOURNAL_ENTRY_PATTERN_NO"
  alias_attribute :journal_entry_pattern_group_no, "JOURNAL_ENTRY_PATTERN_GROUP_NO"
  alias_attribute :journal_entry_pattern_name, "JOURNAL_ENTRY_PATTERN_NAME"
  alias_attribute :row_no, "ROW_NO"
  alias_attribute :date_pattern_no, "DATE_PATTERN_NO"
  alias_attribute :debit_department_no, "DEBIT_DEPARTMENT_NO"
  alias_attribute :debit_account_no, "DEBIT_ACCOUNT_NO"
  alias_attribute :debit_sub_account_no, "DEBIT_SUB_ACCOUNT_NO"
  alias_attribute :debit_tax_rate, "DEBIT_TAX_RATE"
  alias_attribute :debit_tax_class_no, "DEBIT_TAX_CLASS"
  alias_attribute :credit_department_no, "CREDIT_DEPARTMENT_NO"
  alias_attribute :credit_account_no, "CREDIT_ACCOUNT_NO"
  alias_attribute :credit_sub_account_no, "CREDIT_SUB_ACCOUNT_NO"
  alias_attribute :credit_tax_rate, "CREDIT_TAX_RATE"
  alias_attribute :credit_tax_class_no, "CREDIT_TAX_CLASS"
  alias_attribute :fixed_amount_flag, "FIXED_AMOUNT_FLG"
  alias_attribute :fixed_amount, "FIXED_AMOUNT"
  alias_attribute :filter_ratio_flag, "FILTER_RATIO_FLG"
  alias_attribute :filter_ratio, "FILTER_RATIO"
  alias_attribute :filter_amount_flag, "FILTER_AMOUNT_FLG"
  alias_attribute :filter_amount, "FILTER_AMOUNT"
  alias_attribute :detail_division_no, "DETAIL_DIVISION_NO"
  alias_attribute :include_tax_flag, "INCLUDE_TAX_FLG"
  alias_attribute :tax_calc_flag, "TAX_CALC_FLG"
  alias_attribute :accure_flag, "ACCURE_FLG"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :abstract, "ABSTRACT"

  scope :ordered, -> { order(:journal_entry_pattern_group_no, :row_no) }

  belongs_to :company, class_name: "Company", foreign_key: :company_id, optional: true
  belongs_to :debit_department, class_name: "Department", foreign_key: "DEBIT_DEPARTMENT_NO", optional: true
  belongs_to :credit_department, class_name: "Department", foreign_key: "CREDIT_DEPARTMENT_NO", optional: true
  belongs_to :debit_account, class_name: "Account", foreign_key: "DEBIT_ACCOUNT_NO", optional: true
  belongs_to :debit_sub_account, class_name: "SubAccount", foreign_key: "DEBIT_SUB_ACCOUNT_NO",
                                 primary_key: "SUB_ACCOUNT_NO", optional: true
  belongs_to :debit_supplier, class_name: "Supplier", foreign_key: :debit_supplier_id, optional: true
  belongs_to :debit_tax_class, class_name: "TaxClass", foreign_key: "DEBIT_TAX_CLASS", optional: true
  belongs_to :credit_account, class_name: "Account", foreign_key: "CREDIT_ACCOUNT_NO", optional: true
  belongs_to :credit_sub_account, class_name: "SubAccount", foreign_key: "CREDIT_SUB_ACCOUNT_NO",
                                  primary_key: "SUB_ACCOUNT_NO", optional: true
  belongs_to :credit_supplier, class_name: "Supplier", foreign_key: :credit_supplier_id, optional: true
  belongs_to :credit_tax_class, class_name: "TaxClass", foreign_key: "CREDIT_TAX_CLASS", optional: true
  belongs_to :detail_division, class_name: "DetailDivision", foreign_key: "DETAIL_DIVISION_NO", optional: true
end
