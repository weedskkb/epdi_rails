# frozen_string_literal: true

class Supplier < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }
end
