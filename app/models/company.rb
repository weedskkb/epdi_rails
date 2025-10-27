# frozen_string_literal: true

class Company < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }

  belongs_to :supplier, optional: true
  has_many :departments, foreign_key: :company_id, inverse_of: :company
  has_many :capture_records, class_name: "TrnCaptureRecord", foreign_key: :company_id, inverse_of: :company
  has_many :journal_entry_patterns, class_name: "JournalEntryPattern", foreign_key: :company_id, inverse_of: :company
  has_many :journal_entry_data, class_name: "TrnJournalEntryData", foreign_key: :company_id, inverse_of: :company

  alias_method :capture_data, :capture_records
  alias_method :capture_data=, :capture_records=
end
