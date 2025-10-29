# frozen_string_literal: true

class Department < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }

  alias_attribute :department_name, :name

  belongs_to :company, class_name: "Company", foreign_key: :company_id, optional: true

  # 仮実装：KKB側で実装
  def get_company_code(day, get_future=false)
    Company.find_by_code(self.company_id)&.code
  end

  def get_company(day)
    Company.find_by_code(self.company_id)
  end
end
