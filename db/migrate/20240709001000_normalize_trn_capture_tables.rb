class NormalizeTrnCaptureTables < ActiveRecord::Migration[8.0]
  def up
    remove_capture_data_foreign_key
    remove_capture_data_index

    rename_table :"TRN_CAPTURE_HISTORY", :trn_capture_histories if table_exists?(:"TRN_CAPTURE_HISTORY") && !table_exists?(:trn_capture_histories)
    rename_table :"TRN_CAPTURE_DATA", :trn_capture_data if table_exists?(:"TRN_CAPTURE_DATA") && !table_exists?(:trn_capture_data)

    rename_column_if_exists :trn_capture_histories, :"CAPTURE_HISTORY_NO", :id
    rename_column_if_exists :trn_capture_histories, :"ACCRUAL_MONTH", :accrual_month
    rename_column_if_exists :trn_capture_histories, :"PAYMENT_MONTH", :payment_month
    rename_column_if_exists :trn_capture_histories, :"LOCK_FLG", :lock_flg
    rename_column_if_exists :trn_capture_histories, :"CREATE_USER_ID", :created_by_id
    rename_column_if_exists :trn_capture_histories, :"CREATE_DATE", :created_at

    rename_column_if_exists :trn_capture_data, :"CAPTURE_DATA_NO", :id
    rename_column_if_exists :trn_capture_data, :"CAPTURE_HISTORY_NO", :capture_history_id
    rename_column_if_exists :trn_capture_data, :"ROW_NO", :row_no
    rename_column_if_exists :trn_capture_data, :"AMMOUNT", :amount
    rename_column_if_exists :trn_capture_data, :"SECOND_AMMOUNT", :second_amount
    rename_column_if_exists :trn_capture_data, :"CREATE_USER_ID", :created_by_id
    rename_column_if_exists :trn_capture_data, :"CREATE_DATE", :created_at
    rename_column_if_exists :trn_capture_data, :"LIST_CD", :list_cd

    rename_column :"TRN_JOURNAL_ENTRY_HISTORY", :"CAPTURE_HISTORY_NO", :capture_history_id if column_exists?(:"TRN_JOURNAL_ENTRY_HISTORY", :"CAPTURE_HISTORY_NO")

    add_index :trn_capture_data, :capture_history_id unless index_exists?(:trn_capture_data, :capture_history_id)
    add_foreign_key :trn_capture_data, :trn_capture_histories, column: :capture_history_id unless foreign_key_exists?(:trn_capture_data, :trn_capture_histories, column: :capture_history_id)
  end

  def down
    remove_foreign_key :trn_capture_data, :trn_capture_histories if foreign_key_exists?(:trn_capture_data, :trn_capture_histories)
    remove_index :trn_capture_data, :capture_history_id if index_exists?(:trn_capture_data, :capture_history_id)

    rename_column :"TRN_JOURNAL_ENTRY_HISTORY", :capture_history_id, :"CAPTURE_HISTORY_NO"

    rename_column :trn_capture_data, :list_cd, :"LIST_CD"
    rename_column :trn_capture_data, :created_at, :"CREATE_DATE"
    rename_column :trn_capture_data, :created_by_id, :"CREATE_USER_ID"
    rename_column :trn_capture_data, :second_amount, :"SECOND_AMMOUNT"
    rename_column :trn_capture_data, :amount, :"AMMOUNT"
    rename_column :trn_capture_data, :row_no, :"ROW_NO"
    rename_column :trn_capture_data, :capture_history_id, :"CAPTURE_HISTORY_NO"
    rename_column :trn_capture_data, :id, :"CAPTURE_DATA_NO"

    rename_column :trn_capture_histories, :created_at, :"CREATE_DATE"
    rename_column :trn_capture_histories, :created_by_id, :"CREATE_USER_ID"
    rename_column :trn_capture_histories, :lock_flg, :"LOCK_FLG"
    rename_column :trn_capture_histories, :payment_month, :"PAYMENT_MONTH"
    rename_column :trn_capture_histories, :accrual_month, :"ACCRUAL_MONTH"
    rename_column :trn_capture_histories, :id, :"CAPTURE_HISTORY_NO"

    rename_table :trn_capture_data, :"TRN_CAPTURE_DATA"
    rename_table :trn_capture_histories, :"TRN_CAPTURE_HISTORY"

    add_index :"TRN_CAPTURE_DATA", :"CAPTURE_HISTORY_NO" unless index_exists?(:"TRN_CAPTURE_DATA", :"CAPTURE_HISTORY_NO")
    add_foreign_key :"TRN_CAPTURE_DATA", :"TRN_CAPTURE_HISTORY",
                    column: :"CAPTURE_HISTORY_NO", primary_key: :"CAPTURE_HISTORY_NO"
  end

  private

  def remove_capture_data_foreign_key
    if table_exists?(:"TRN_CAPTURE_DATA") && foreign_key_exists?(:"TRN_CAPTURE_DATA", :"TRN_CAPTURE_HISTORY", column: :"CAPTURE_HISTORY_NO")
      remove_foreign_key :"TRN_CAPTURE_DATA", column: :"CAPTURE_HISTORY_NO"
    elsif table_exists?(:trn_capture_data) && foreign_key_exists?(:trn_capture_data, :trn_capture_histories, column: :"CAPTURE_HISTORY_NO")
      remove_foreign_key :trn_capture_data, column: :"CAPTURE_HISTORY_NO"
    end
  end

  def remove_capture_data_index
    if table_exists?(:"TRN_CAPTURE_DATA") && index_exists?(:"TRN_CAPTURE_DATA", :"CAPTURE_HISTORY_NO")
      remove_index :"TRN_CAPTURE_DATA", column: :"CAPTURE_HISTORY_NO"
    elsif table_exists?(:trn_capture_data) && index_exists?(:trn_capture_data, :"CAPTURE_HISTORY_NO")
      remove_index :trn_capture_data, column: :"CAPTURE_HISTORY_NO"
    end
  end

  def rename_column_if_exists(table, old_name, new_name)
    return unless table_exists?(table)
    return unless column_exists?(table, old_name)

    rename_column table, old_name, new_name
  end
end
