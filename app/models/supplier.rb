# frozen_string_literal: true

class Supplier < ApplicationRecord
  self.table_name = "MST_SUPPLIER"
  self.primary_key = "SUPPLIER_NO"

  alias_attribute :supplier_no, "SUPPLIER_NO"
  alias_attribute :supplier_name, "SUPPLIER_NAME"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :update_user_id, "UPDATE_USER_ID"
  alias_attribute :update_date, "UPDATE_DATE"

  scope :active, -> { where(DELETE_FLG: false) }
end
