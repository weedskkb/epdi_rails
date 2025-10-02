# frozen_string_literal: true

class JournalEntryPattern < ApplicationRecord
  self.table_name = "MST_JOURNAL_ENTRY_PATTERN"
  self.primary_key = "JOURNAL_ENTRY_PATTERN_NO"

  alias_attribute :journal_entry_pattern_no, "JOURNAL_ENTRY_PATTERN_NO"
  alias_attribute :journal_entry_pattern_group_no, "JOURNAL_ENTRY_PATTERN_GROUP_NO"
  alias_attribute :journal_entry_pattern_name, "JOURNAL_ENTRY_PATTERN_NAME"
  alias_attribute :row_no, "ROW_NO"

  scope :ordered, -> { order(:journal_entry_pattern_group_no, :row_no) }

  belongs_to :company, class_name: "Company", foreign_key: "COMPANY_NO", optional: true
  belongs_to :debit_department, class_name: "Department", foreign_key: "DEBIT_DEPARTMENT_NO", optional: true
  belongs_to :credit_department, class_name: "Department", foreign_key: "CREDIT_DEPARTMENT_NO", optional: true
end
