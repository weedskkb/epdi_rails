# frozen_string_literal: true

class TaxClass < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }
end
