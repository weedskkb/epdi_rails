# frozen_string_literal: true

class TrnCaptureHistory < ApplicationRecord
  self.table_name = "TRN_CAPTURE_HISTORY"
  self.primary_key = "CAPTURE_HISTORY_NO"

  alias_attribute :capture_history_no, "CAPTURE_HISTORY_NO"
  alias_attribute :capture_category_no, "CAPTURE_CATEGORY_NO"
  alias_attribute :target_month, "TARGET_MONTH"
  alias_attribute :overwrite, "OVERWRITE"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :update_user_id, "UPDATE_USER_ID"
  alias_attribute :update_date, "UPDATE_DATE"

  belongs_to :capture_category, class_name: "CaptureCategory", foreign_key: "CAPTURE_CATEGORY_NO"
  has_many :capture_data, class_name: "TrnCaptureData", foreign_key: "CAPTURE_HISTORY_NO"
  has_many :journal_entry_data, class_name: "TrnJournalEntryData", foreign_key: "CAPTURE_HISTORY_NO"
end
