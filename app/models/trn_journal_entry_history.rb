# frozen_string_literal: true

class TrnJournalEntryHistory < ApplicationRecord
  belongs_to :capture_category, class_name: "CaptureCategory", foreign_key: :capture_category_id
  belongs_to :capture_history, class_name: "TrnCaptureHistory", foreign_key: :capture_history_id
  has_many :journal_entry_records, class_name: "TrnJournalEntryRecord", foreign_key: :journal_entry_history_id, inverse_of: :journal_entry_history
end
