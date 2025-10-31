# frozen_string_literal: true

class SwitchTrnDepartmentIdsToCodes < ActiveRecord::Migration[8.0]
  TABLE_COLUMN_MAPPINGS = {
    trn_capture_records: [:department_code],
    trn_journal_entry_records: [:department_code, :debit_department_code, :credit_department_code],
    capture_categories: [:debit_department_code, :credit_department_code],
    journal_entry_patterns: [:debit_department_code, :credit_department_code]
  }.freeze

  def up
    rename_columns_to_codes

    remove_index :trn_capture_records, column: :department_code if index_exists?(:trn_capture_records, :department_code)

    change_column :trn_capture_records, :department_code, :string
    # change_column_null :trn_capture_records, :department_code, false

    change_column :trn_journal_entry_records, :department_code, :string
    change_column :trn_journal_entry_records, :debit_department_code, :string
    change_column :trn_journal_entry_records, :credit_department_code, :string

    change_column :capture_categories, :debit_department_code, :string
    change_column :capture_categories, :credit_department_code, :string

    change_column :journal_entry_patterns, :debit_department_code, :string
    change_column :journal_entry_patterns, :credit_department_code, :string

    add_index :trn_capture_records, :department_code unless index_exists?(:trn_capture_records, :department_code)
    add_index :trn_journal_entry_records, :department_code unless index_exists?(:trn_journal_entry_records, :department_code)
    add_index :trn_journal_entry_records, :debit_department_code unless index_exists?(:trn_journal_entry_records, :debit_department_code)
    add_index :trn_journal_entry_records, :credit_department_code unless index_exists?(:trn_journal_entry_records, :credit_department_code)
  end

  def down
    remove_index :trn_capture_records, :department_code if index_exists?(:trn_capture_records, :department_code)
    remove_index :trn_journal_entry_records, :department_code if index_exists?(:trn_journal_entry_records, :department_code)
    remove_index :trn_journal_entry_records, :debit_department_code if index_exists?(:trn_journal_entry_records, :debit_department_code)
    remove_index :trn_journal_entry_records, :credit_department_code if index_exists?(:trn_journal_entry_records, :credit_department_code)

    change_column :trn_capture_records, :department_code, :integer
    change_column_null :trn_capture_records, :department_code, false

    change_column :trn_journal_entry_records, :department_code, :integer
    change_column :trn_journal_entry_records, :debit_department_code, :integer
    change_column :trn_journal_entry_records, :credit_department_code, :integer

    change_column :capture_categories, :debit_department_code, :integer
    change_column :capture_categories, :credit_department_code, :integer

    change_column :journal_entry_patterns, :debit_department_code, :integer
    change_column :journal_entry_patterns, :credit_department_code, :integer

    rename_columns_to_ids

    add_index :trn_capture_records, :department_id unless index_exists?(:trn_capture_records, :department_id)
  end

  private

  def rename_columns_to_codes
    rename_column :trn_capture_records, :department_id, :department_code

    rename_column :trn_journal_entry_records, :department_id, :department_code
    rename_column :trn_journal_entry_records, :debit_department_id, :debit_department_code
    rename_column :trn_journal_entry_records, :credit_department_id, :credit_department_code

    rename_column :capture_categories, :debit_department_id, :debit_department_code
    rename_column :capture_categories, :credit_department_id, :credit_department_code

    rename_column :journal_entry_patterns, :debit_department_id, :debit_department_code
    rename_column :journal_entry_patterns, :credit_department_id, :credit_department_code
  end

  def rename_columns_to_ids
    rename_column :trn_capture_records, :department_code, :department_id

    rename_column :trn_journal_entry_records, :department_code, :department_id
    rename_column :trn_journal_entry_records, :debit_department_code, :debit_department_id
    rename_column :trn_journal_entry_records, :credit_department_code, :credit_department_id

    rename_column :capture_categories, :debit_department_code, :debit_department_id
    rename_column :capture_categories, :credit_department_code, :credit_department_id

    rename_column :journal_entry_patterns, :debit_department_code, :debit_department_id
    rename_column :journal_entry_patterns, :credit_department_code, :credit_department_id
  end
end
