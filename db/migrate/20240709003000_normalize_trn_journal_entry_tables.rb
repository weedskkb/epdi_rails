class NormalizeTrnJournalEntryTables < ActiveRecord::Migration[8.0]
  def up
    rename_table_if_needed :"TRN_JOURNAL_ENTRY_HISTORY", :trn_journal_entry_histories
    rename_table_if_needed :"TRN_JOURNAL_ENTRY_DATA", :trn_journal_entry_records

    rename_history_columns
    rename_data_columns
  end

  def down
    revert_data_columns
    revert_history_columns

    rename_table_if_needed :trn_journal_entry_records, :"TRN_JOURNAL_ENTRY_DATA"
    rename_table_if_needed :trn_journal_entry_histories, :"TRN_JOURNAL_ENTRY_HISTORY"
  end

  private

  def rename_history_columns
    table = :trn_journal_entry_histories
    return unless table_exists?(table)

    rename_column_if_exists table, :"JOURNAL_ENTRY_HISTORY_NO", :id
    rename_column_if_exists table, :"ACCRUAL_MONTH", :accrual_month
    rename_column_if_exists table, :"PAYMENT_MONTH", :payment_month
    rename_column_if_exists table, :"EXECUTE_FLG", :execute_flag
    rename_column_if_exists table, :"CREATE_USER_ID", :created_by_id
    rename_column_if_exists table, :"CREATE_DATE", :created_at
  end

  def rename_data_columns
    table = :trn_journal_entry_records
    return unless table_exists?(table)

    rename_column_if_exists table, :"JOURNAL_ENTRY_DATA_NO", :id
    rename_column_if_exists table, :"JOURNAL_ENTRY_HISTORY_NO", :journal_entry_history_id
    rename_column_if_exists table, :"EXCEL_ROW_NO", :excel_row_no
    rename_column_if_exists table, :"ROW_NO", :row_no
    rename_column_if_exists table, :"DATE", :date
    rename_column_if_exists table, :"DEBIT_AMMOUNT", :debit_amount
    rename_column_if_exists table, :"CREDIT_AMMOUNT", :credit_amount
    rename_column_if_exists table, :"ABSTRACT", :abstract
    rename_column_if_exists table, :"CREATE_DATE", :created_at
    rename_column_if_exists table, :"CREATE_USER_ID", :created_by_id
  end

  def revert_history_columns
    table = table_exists?(:trn_journal_entry_histories) ? :trn_journal_entry_histories : :"TRN_JOURNAL_ENTRY_HISTORY"
    rename_column_if_exists table, :created_at, :"CREATE_DATE"
    rename_column_if_exists table, :created_by_id, :"CREATE_USER_ID"
    rename_column_if_exists table, :execute_flag, :"EXECUTE_FLG"
    rename_column_if_exists table, :payment_month, :"PAYMENT_MONTH"
    rename_column_if_exists table, :accrual_month, :"ACCRUAL_MONTH"
    rename_column_if_exists table, :id, :"JOURNAL_ENTRY_HISTORY_NO"
  end

  def revert_data_columns
    table = table_exists?(:trn_journal_entry_records) ? :trn_journal_entry_records : :"TRN_JOURNAL_ENTRY_DATA"
    rename_column_if_exists table, :created_by_id, :"CREATE_USER_ID"
    rename_column_if_exists table, :created_at, :"CREATE_DATE"
    rename_column_if_exists table, :abstract, :"ABSTRACT"
    rename_column_if_exists table, :credit_amount, :"CREDIT_AMMOUNT"
    rename_column_if_exists table, :debit_amount, :"DEBIT_AMMOUNT"
    rename_column_if_exists table, :date, :"DATE"
    rename_column_if_exists table, :row_no, :"ROW_NO"
    rename_column_if_exists table, :excel_row_no, :"EXCEL_ROW_NO"
    rename_column_if_exists table, :journal_entry_history_id, :"JOURNAL_ENTRY_HISTORY_NO"
    rename_column_if_exists table, :id, :"JOURNAL_ENTRY_DATA_NO"
  end

  def rename_table_if_needed(old_name, new_name)
    return unless table_exists?(old_name)
    return if table_exists?(new_name)

    rename_table old_name, new_name
  end

  def rename_column_if_exists(table, old_name, new_name)
    return unless column_exists?(table, old_name)

    rename_column table, old_name, new_name
  end
end
