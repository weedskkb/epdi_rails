class UpdateSupplierReferencesToBusinessConnectionCodes < ActiveRecord::Migration[8.0]
  def up
    rename_column :capture_categories, :supplier_id, :business_connection_code
    change_column :capture_categories, :business_connection_code, :string

    rename_column :companies, :supplier_id, :business_connection_code
    change_column :companies, :business_connection_code, :string

    rename_column :trn_capture_records, :supplier_id, :business_connection_code
    change_column :trn_capture_records, :business_connection_code, :string

    rename_column :journal_entry_patterns, :debit_supplier_id, :debit_business_connection_code
    change_column :journal_entry_patterns, :debit_business_connection_code, :string

    rename_column :journal_entry_patterns, :credit_supplier_id, :credit_business_connection_code
    change_column :journal_entry_patterns, :credit_business_connection_code, :string

    rename_column :trn_journal_entry_records, :debit_supplier_id, :debit_business_connection_code
    change_column :trn_journal_entry_records, :debit_business_connection_code, :string

    rename_column :trn_journal_entry_records, :credit_supplier_id, :credit_business_connection_code
    change_column :trn_journal_entry_records, :credit_business_connection_code, :string
  end

  def down
    change_column :trn_journal_entry_records, :credit_business_connection_code, :integer
    rename_column :trn_journal_entry_records, :credit_business_connection_code, :credit_supplier_id

    change_column :trn_journal_entry_records, :debit_business_connection_code, :integer
    rename_column :trn_journal_entry_records, :debit_business_connection_code, :debit_supplier_id

    change_column :journal_entry_patterns, :credit_business_connection_code, :integer
    rename_column :journal_entry_patterns, :credit_business_connection_code, :credit_supplier_id

    change_column :journal_entry_patterns, :debit_business_connection_code, :integer
    rename_column :journal_entry_patterns, :debit_business_connection_code, :debit_supplier_id

    change_column :trn_capture_records, :business_connection_code, :integer
    rename_column :trn_capture_records, :business_connection_code, :supplier_id

    change_column :companies, :business_connection_code, :integer
    rename_column :companies, :business_connection_code, :supplier_id

    change_column :capture_categories, :business_connection_code, :integer
    rename_column :capture_categories, :business_connection_code, :supplier_id
  end
end
