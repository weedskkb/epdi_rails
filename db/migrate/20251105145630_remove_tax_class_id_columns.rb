# frozen_string_literal: true

class RemoveTaxClassIdColumns < ActiveRecord::Migration[8.0]
  def up
    remove_column :capture_categories, :tax_class_id, if_exists: true
    remove_column :trn_capture_records, :tax_class_id, if_exists: true
    remove_column :journal_entry_patterns, :debit_tax_class_id, if_exists: true
    remove_column :journal_entry_patterns, :credit_tax_class_id, if_exists: true
    remove_column :trn_journal_entry_records, :debit_tax_class_id, if_exists: true
    remove_column :trn_journal_entry_records, :credit_tax_class_id, if_exists: true
  end

  def down
    add_column :capture_categories, :tax_class_id, :integer, if_not_exists: true
    add_column :trn_capture_records, :tax_class_id, :integer, if_not_exists: true
    add_column :journal_entry_patterns, :debit_tax_class_id, :integer, if_not_exists: true
    add_column :journal_entry_patterns, :credit_tax_class_id, :integer, if_not_exists: true
    add_column :trn_journal_entry_records, :debit_tax_class_id, :integer, if_not_exists: true
    add_column :trn_journal_entry_records, :credit_tax_class_id, :integer, if_not_exists: true
  end
end
