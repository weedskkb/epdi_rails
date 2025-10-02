# frozen_string_literal: true

class Authority < ApplicationRecord
  self.table_name = "MST_AUTHOLITY"
  self.primary_key = "AUTHOLITY_NO"

  alias_attribute :autholity_no, "AUTHOLITY_NO"
  alias_attribute :autholity_name, "AUTHOLITY_NAME"
  alias_attribute :delete_flg, "DELETE_FLG"

  scope :active, -> { where(DELETE_FLG: false) }

  has_many :users, class_name: "TrnUser", foreign_key: "AUTHOLITY_NO"
end
