class RenameAccountNumberColumns < ActiveRecord::Migration[8.0]
  def up
    rename_column :"MST_CAPTURE_CATEGORY", :"DEBIT_ACCOUNT_NO", :debit_account_code if column_exists?(:"MST_CAPTURE_CATEGORY", :"DEBIT_ACCOUNT_NO")
    rename_column :"MST_CAPTURE_CATEGORY", :"DEBIT_SUB_ACCOUNT_NO", :debit_account_sub_code if column_exists?(:"MST_CAPTURE_CATEGORY", :"DEBIT_SUB_ACCOUNT_NO")
    rename_column :"MST_CAPTURE_CATEGORY", :"CREDIT_ACCOUNT_NO", :credit_account_code if column_exists?(:"MST_CAPTURE_CATEGORY", :"CREDIT_ACCOUNT_NO")
    rename_column :"MST_CAPTURE_CATEGORY", :"CREDIT_SUB_ACCOUNT_NO", :credit_account_sub_code if column_exists?(:"MST_CAPTURE_CATEGORY", :"CREDIT_SUB_ACCOUNT_NO")

    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"DEBIT_ACCOUNT_NO", :debit_account_code if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :"DEBIT_ACCOUNT_NO")
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"DEBIT_SUB_ACCOUNT_NO", :debit_account_sub_code if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :"DEBIT_SUB_ACCOUNT_NO")
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"CREDIT_ACCOUNT_NO", :credit_account_code if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :"CREDIT_ACCOUNT_NO")
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"CREDIT_SUB_ACCOUNT_NO", :credit_account_sub_code if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :"CREDIT_SUB_ACCOUNT_NO")

    rename_column :"TRN_CAPTURE_DATA", :"ACCOUNT_NO", :account_code if column_exists?(:"TRN_CAPTURE_DATA", :"ACCOUNT_NO")
    rename_column :"TRN_CAPTURE_DATA", :"SUB_ACCOUNT_NO", :account_sub_code if column_exists?(:"TRN_CAPTURE_DATA", :"SUB_ACCOUNT_NO")

    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"DEBIT_ACCOUNT_NO", :debit_account_code if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :"DEBIT_ACCOUNT_NO")
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"DEBIT_SUB_ACCOUNT_NO", :debit_account_sub_code if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :"DEBIT_SUB_ACCOUNT_NO")
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"CREDIT_ACCOUNT_NO", :credit_account_code if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :"CREDIT_ACCOUNT_NO")
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"CREDIT_SUB_ACCOUNT_NO", :credit_account_sub_code if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :"CREDIT_SUB_ACCOUNT_NO")
  end

  def down
    rename_column :"MST_CAPTURE_CATEGORY", :debit_account_code, :"DEBIT_ACCOUNT_NO" if column_exists?(:"MST_CAPTURE_CATEGORY", :debit_account_code)
    rename_column :"MST_CAPTURE_CATEGORY", :debit_account_sub_code, :"DEBIT_SUB_ACCOUNT_NO" if column_exists?(:"MST_CAPTURE_CATEGORY", :debit_account_sub_code)
    rename_column :"MST_CAPTURE_CATEGORY", :credit_account_code, :"CREDIT_ACCOUNT_NO" if column_exists?(:"MST_CAPTURE_CATEGORY", :credit_account_code)
    rename_column :"MST_CAPTURE_CATEGORY", :credit_account_sub_code, :"CREDIT_SUB_ACCOUNT_NO" if column_exists?(:"MST_CAPTURE_CATEGORY", :credit_account_sub_code)

    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :debit_account_code, :"DEBIT_ACCOUNT_NO" if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :debit_account_code)
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :debit_account_sub_code, :"DEBIT_SUB_ACCOUNT_NO" if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :debit_account_sub_code)
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :credit_account_code, :"CREDIT_ACCOUNT_NO" if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :credit_account_code)
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :credit_account_sub_code, :"CREDIT_SUB_ACCOUNT_NO" if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :credit_account_sub_code)

    rename_column :"TRN_CAPTURE_DATA", :account_code, :"ACCOUNT_NO" if column_exists?(:"TRN_CAPTURE_DATA", :account_code)
    rename_column :"TRN_CAPTURE_DATA", :account_sub_code, :"SUB_ACCOUNT_NO" if column_exists?(:"TRN_CAPTURE_DATA", :account_sub_code)

    rename_column :"TRN_JOURNAL_ENTRY_DATA", :debit_account_code, :"DEBIT_ACCOUNT_NO" if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :debit_account_code)
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :debit_account_sub_code, :"DEBIT_SUB_ACCOUNT_NO" if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :debit_account_sub_code)
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :credit_account_code, :"CREDIT_ACCOUNT_NO" if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :credit_account_code)
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :credit_account_sub_code, :"CREDIT_SUB_ACCOUNT_NO" if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :credit_account_sub_code)
  end
end
