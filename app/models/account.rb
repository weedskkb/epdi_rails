# frozen_string_literal: true

class Account < ApplicationRecord
  self.table_name = "MST_ACCOUNT"
  self.primary_key = "ACCOUNT_NO"

  alias_attribute :account_no, "ACCOUNT_NO"
  alias_attribute :account_name, "ACCOUNT_NAME"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :update_user_id, "UPDATE_USER_ID"
  alias_attribute :update_date, "UPDATE_DATE"

  scope :active, -> { where(DELETE_FLG: false) }

  has_many :sub_accounts, class_name: "SubAccount", foreign_key: "ACCOUNT_NO"
end
