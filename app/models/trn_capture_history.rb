# frozen_string_literal: true

class TrnCaptureHistory < ApplicationRecord
  self.table_name = "TRN_CAPTURE_HISTORY"
  self.primary_key = "CAPTURE_HISTORY_NO"

  alias_attribute :capture_history_no, "CAPTURE_HISTORY_NO"
  alias_attribute :capture_category_no, "CAPTURE_CATEGORY_NO"
  alias_attribute :accrual_month, "ACCRUAL_MONTH"
  alias_attribute :payment_month, "PAYMENT_MONTH"
  alias_attribute :lock_flg, "LOCK_FLG"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :create_date, "CREATE_DATE"

  belongs_to :capture_category, class_name: "CaptureCategory", foreign_key: "CAPTURE_CATEGORY_NO"
  has_many :capture_data, class_name: "TrnCaptureData", foreign_key: "CAPTURE_HISTORY_NO"
  has_many :journal_entry_histories, class_name: "TrnJournalEntryHistory", foreign_key: "CAPTURE_HISTORY_NO"
  has_many :journal_entry_data, through: :journal_entry_histories
end
