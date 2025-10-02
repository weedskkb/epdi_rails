# frozen_string_literal: true

class TaxRate < ApplicationRecord
  self.table_name = "MST_TAX_RATE"
  self.primary_key = "TAX_RATE_NO"

  alias_attribute :tax_rate_no, "TAX_RATE_NO"
  alias_attribute :tax_rate, "TAX_RATE"
  alias_attribute :delete_flg, "DELETE_FLG"

  scope :active, -> { where(DELETE_FLG: false) }
end
