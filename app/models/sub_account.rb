# frozen_string_literal: true

class SubAccount < ApplicationRecord
  self.table_name = "MST_SUB_ACCOUNT"
  self.primary_key = "ID"

  alias_attribute :id, "ID"
  alias_attribute :sub_account_no, "SUB_ACCOUNT_NO"
  alias_attribute :sub_account_name, "SUB_ACCOUNT_NAME"
  alias_attribute :account_no, "ACCOUNT_NO"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :update_user_id, "UPDATE_USER_ID"
  alias_attribute :update_date, "UPDATE_DATE"

  scope :active, -> { where(DELETE_FLG: false) }

  belongs_to :account, class_name: "Account", foreign_key: "ACCOUNT_NO"
end
