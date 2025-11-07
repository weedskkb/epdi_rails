# frozen_string_literal: true

class RemoveTaxRateIdColumns < ActiveRecord::Migration[8.0]
  def up
    remove_column :capture_categories, :tax_rate_id, if_exists: true
    remove_column :trn_capture_records, :tax_rate_id, if_exists: true
    remove_column :journal_entry_patterns, :debit_tax_rate_id, if_exists: true
    remove_column :journal_entry_patterns, :credit_tax_rate_id, if_exists: true
    remove_column :trn_journal_entry_records, :debit_tax_rate_id, if_exists: true
    remove_column :trn_journal_entry_records, :credit_tax_rate_id, if_exists: true
  end

  def down
    add_tax_rate_id_column(:capture_categories, :tax_rate_id)
    add_tax_rate_id_column(:trn_capture_records, :tax_rate_id)
    add_tax_rate_id_column(:journal_entry_patterns, :debit_tax_rate_id)
    add_tax_rate_id_column(:journal_entry_patterns, :credit_tax_rate_id)
    add_tax_rate_id_column(:trn_journal_entry_records, :debit_tax_rate_id)
    add_tax_rate_id_column(:trn_journal_entry_records, :credit_tax_rate_id)
  end

  private

  def add_tax_rate_id_column(table, column)
    add_column(table, column, :integer) unless column_exists?(table, column)
  end
end
