# frozen_string_literal: true

class Company < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }

  belongs_to :business_connection,
             class_name: "BusinessConnection",
             foreign_key: :business_connection_code,
             primary_key: :code,
             optional: true
  has_many :departments, foreign_key: :company_id, inverse_of: :company
  has_many :capture_records, class_name: "TrnCaptureRecord", foreign_key: :company_id, inverse_of: :company
  has_many :journal_entry_patterns, class_name: "JournalEntryPattern", foreign_key: :company_id, inverse_of: :company
  has_many :journal_entry_records, class_name: "TrnJournalEntryRecord", foreign_key: :company_id, inverse_of: :company

  alias_method :capture_data, :capture_records
  alias_method :capture_data=, :capture_records=
  alias_method :journal_entry_data, :journal_entry_records
  alias_method :journal_entry_data=, :journal_entry_records=
end
