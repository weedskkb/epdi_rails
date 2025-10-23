# frozen_string_literal: true

class TaxRate < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }
end
