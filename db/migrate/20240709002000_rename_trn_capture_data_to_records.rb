class RenameTrnCaptureDataToRecords < ActiveRecord::Migration[8.0]
  def up
    if table_exists?(:trn_capture_data) && !table_exists?(:trn_capture_records)
      rename_table :trn_capture_data, :trn_capture_records
    end

    rename_index_if_exists :trn_capture_records,
                           "index_trn_capture_data_on_capture_history_id",
                           "index_trn_capture_records_on_capture_history_id"

    rename_index_if_exists :trn_capture_records,
                           "index_trn_capture_data_on_department_id",
                           "index_trn_capture_records_on_department_id"
  end

  def down
    rename_index_if_exists :trn_capture_records,
                           "index_trn_capture_records_on_capture_history_id",
                           "index_trn_capture_data_on_capture_history_id"

    rename_index_if_exists :trn_capture_records,
                           "index_trn_capture_records_on_department_id",
                           "index_trn_capture_data_on_department_id"

    if table_exists?(:trn_capture_records) && !table_exists?(:trn_capture_data)
      rename_table :trn_capture_records, :trn_capture_data
    end
  end

  private

  def rename_index_if_exists(table, old_name, new_name)
    return unless index_name_exists?(table, old_name)

    rename_index table, old_name, new_name
  end
end
