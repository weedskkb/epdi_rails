# frozen_string_literal: true

class TrnJournalEntryHistory < ApplicationRecord
  self.table_name = "TRN_JOURNAL_ENTRY_HISTORY"
  self.primary_key = "JOURNAL_ENTRY_HISTORY_NO"

  alias_attribute :journal_entry_history_no, "JOURNAL_ENTRY_HISTORY_NO"
  alias_attribute :capture_category_no, "CAPTURE_CATEGORY_NO"
  alias_attribute :capture_history_no, "CAPTURE_HISTORY_NO"
  alias_attribute :accrual_month, "ACCRUAL_MONTH"
  alias_attribute :payment_month, "PAYMENT_MONTH"
  alias_attribute :execute_flg, "EXECUTE_FLG"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :create_date, "CREATE_DATE"

  belongs_to :capture_category, class_name: "CaptureCategory", foreign_key: "CAPTURE_CATEGORY_NO"
  belongs_to :capture_history, class_name: "TrnCaptureHistory", foreign_key: "CAPTURE_HISTORY_NO"
  has_many :journal_entry_data, class_name: "TrnJournalEntryData", foreign_key: "JOURNAL_ENTRY_HISTORY_NO"
end
