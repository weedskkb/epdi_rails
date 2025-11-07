class Department < ApplicationRecord
  scope :active, -> { where(hidden: false) }
  belongs_to :company, class_name: "Company", foreign_key: :company_id, optional: true

  # TODO: 仮実装 => KKB側で別途実装
  def get_company_code(day, get_future=false)
    Company.find_by_id(company_id)&.code
  end

  def get_company(day)
    Company.find_by_id(company_id)
  end
end
