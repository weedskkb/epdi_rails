# frozen_string_literal: true

class CaptureCategory < ApplicationRecord
  self.table_name = "MST_CAPTURE_CATEGORY"
  self.primary_key = "CAPTURE_CATEGORY_NO"

  alias_attribute :capture_category_no, "CAPTURE_CATEGORY_NO"
  alias_attribute :capture_category_name, "CAPTURE_CATEGORY_NAME"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :journal_entry_pattern_group_no, "JOURNAL_ENTRY_PATTERN_GROUP_NO"
  alias_attribute :tax_rate_no, "TAX_RATE_NO"
  alias_attribute :tax_class_no, "TAX_CLASS_NO"

  scope :active, -> { where(DELETE_FLG: false) }

  belongs_to :tax_rate, class_name: "TaxRate", foreign_key: "TAX_RATE_NO", optional: true
  belongs_to :tax_class, class_name: "TaxClass", foreign_key: "TAX_CLASS_NO", optional: true
end
