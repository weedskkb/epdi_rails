# frozen_string_literal: true

# 未使用
class DetailDivision < ApplicationRecord
  self.table_name = "MST_DETAIL_DIVISION"
  self.primary_key = "DETAIL_DIVISION_NO"

  alias_attribute :detail_division_no, "DETAIL_DIVISION_NO"
  alias_attribute :detail_division_name, "DETAIL_DIVISION_NAME"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :update_user_id, "UPDATE_USER_ID"
  alias_attribute :update_date, "UPDATE_DATE"

  scope :active, -> { where(DELETE_FLG: false) }
end
