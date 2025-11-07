# frozen_string_literal: true

class AddTaxRateCodeColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :capture_categories, :tax_rate_code, :integer, limit: 1
    add_column :trn_capture_records, :tax_rate_code, :integer, limit: 1
    add_column :journal_entry_patterns, :debit_tax_rate_code, :integer, limit: 1
    add_column :journal_entry_patterns, :credit_tax_rate_code, :integer, limit: 1
    add_column :trn_journal_entry_records, :debit_tax_rate_code, :integer, limit: 1
    add_column :trn_journal_entry_records, :credit_tax_rate_code, :integer, limit: 1
  end
end
