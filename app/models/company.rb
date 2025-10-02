# frozen_string_literal: true

class Company < ApplicationRecord
  self.table_name = "MST_COMPANY"
  self.primary_key = "COMPANY_NO"

  alias_attribute :company_no, "COMPANY_NO"
  alias_attribute :company_name, "COMPANY_NAME"
  alias_attribute :supplier_no, "SUPPLIER_NO"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :update_user_id, "UPDATE_USER_ID"
  alias_attribute :update_date, "UPDATE_DATE"

  scope :active, -> { where(DELETE_FLG: false) }

  belongs_to :supplier, class_name: "Supplier", foreign_key: "SUPPLIER_NO", optional: true
end
