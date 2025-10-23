# frozen_string_literal: true

class Department < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }

  alias_attribute :department_name, :name

  belongs_to :company, class_name: "Company", foreign_key: :company_id, optional: true
end
