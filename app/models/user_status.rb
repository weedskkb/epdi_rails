# frozen_string_literal: true

class UserStatus < ApplicationRecord
  self.table_name = "MST_USER_STATUS"
  self.primary_key = "STATUS_NO"

  alias_attribute :status_no, "STATUS_NO"
  alias_attribute :status_name, "STATUS_NAME"
  alias_attribute :delete_flg, "DELETE_FLG"

  scope :active, -> { where(DELETE_FLG: false) }
end
