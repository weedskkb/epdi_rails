# frozen_string_literal: true

class TrnCaptureHistory < ApplicationRecord
  belongs_to :capture_category, class_name: "CaptureCategory", foreign_key: :capture_category_id
  has_many :capture_records, class_name: "TrnCaptureRecord", foreign_key: :capture_history_id, inverse_of: :capture_history
  has_many :journal_entry_histories, class_name: "TrnJournalEntryHistory", foreign_key: :capture_history_id
  has_many :journal_entry_data, through: :journal_entry_histories

  alias_method :capture_data, :capture_records
  alias_method :capture_data=, :capture_records=
end
