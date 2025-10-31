# frozen_string_literal: true

class BsDepartment < ApplicationRecord
  self.table_name = "bs_departments"

  scope :active, -> { where(delete_flg: false) }

  alias_attribute :department_name, :name

  belongs_to :company, class_name: "Company", foreign_key: :company_id, optional: true

  def code
    self.id
  end

  # 仮実装：KKB側で実装
  def get_company_code(day, get_future=false)
    Company.find_by_code(company_id)&.code
  end

  def get_company(day)
    Company.find_by_code(company_id)
  end
end
