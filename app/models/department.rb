# frozen_string_literal: true

class Department < ApplicationRecord
  self.table_name = "MST_DEPARTMENT"
  self.primary_key = "DEPARTMENT_NO"

  alias_attribute :department_no, "DEPARTMENT_NO"
  alias_attribute :department_name, "DEPARTMENT_NAME"
  alias_attribute :company_no, "COMPANY_NO"
  alias_attribute :delete_flg, "DELETE_FLG"

  scope :active, -> { where(DELETE_FLG: false) }

  belongs_to :company, class_name: "Company", foreign_key: "COMPANY_NO"
end
