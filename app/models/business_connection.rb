class BusinessConnection < ApplicationRecord
  scope :active, -> { where(hidden: false) }
end
