# frozen_string_literal: true

class TaxClass < ApplicationRecord
  self.table_name = "MST_TAX_CLASS"
  self.primary_key = "TAX_CLASS_NO"

  alias_attribute :tax_class_no, "TAX_CLASS_NO"
  alias_attribute :tax_class_name, "TAX_CLASS_NAME"
  alias_attribute :delete_flg, "DELETE_FLG"

  scope :active, -> { where(DELETE_FLG: false) }
end
