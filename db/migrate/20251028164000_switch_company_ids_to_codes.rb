class SwitchCompanyIdsToCodes < ActiveRecord::Migration[8.0]
  def up
    rename_column :journal_entry_patterns, :company_id, :company_code
    change_column :journal_entry_patterns, :company_code, :string

    rename_column :trn_capture_records, :company_id, :company_code
    change_column :trn_capture_records, :company_code, :string, null: false

    rename_column :trn_journal_entry_records, :company_id, :company_code
    change_column :trn_journal_entry_records, :company_code, :string, null: false

    rename_column :capture_categories, :supplier_company_id, :business_connection_company_code
    change_column :capture_categories, :business_connection_company_code, :string

  end

  def down
    change_column :capture_categories, :business_connection_company_code, :integer
    rename_column :capture_categories, :business_connection_company_code, :supplier_company_id

    change_column :trn_journal_entry_records, :company_code, :integer, null: false
    rename_column :trn_journal_entry_records, :company_code, :company_id

    change_column :trn_capture_records, :company_code, :integer, null: false
    rename_column :trn_capture_records, :company_code, :company_id

    change_column :journal_entry_patterns, :company_code, :integer
    rename_column :journal_entry_patterns, :company_code, :company_id
  end
end
