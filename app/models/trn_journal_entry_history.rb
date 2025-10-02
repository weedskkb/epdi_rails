# frozen_string_literal: true

class TrnJournalEntryHistory < ApplicationRecord
  self.table_name = "TRN_JOURNAL_ENTRY_HISTORY"
  self.primary_key = "JOURNAL_ENTRY_HISTORY_NO"

  alias_attribute :journal_entry_history_no, "JOURNAL_ENTRY_HISTORY_NO"
  alias_attribute :capture_category_no, "CAPTURE_CATEGORY_NO"
  alias_attribute :target_month, "TARGET_MONTH"
  alias_attribute :delete_flg, "DELETE_FLG"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :update_user_id, "UPDATE_USER_ID"
  alias_attribute :update_date, "UPDATE_DATE"

  belongs_to :capture_category, class_name: "CaptureCategory", foreign_key: "CAPTURE_CATEGORY_NO"
end
