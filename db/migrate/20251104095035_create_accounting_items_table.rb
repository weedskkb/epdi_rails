class CreateAccountingItemsTable < ActiveRecord::Migration[8.0]
  def change
    return if table_exists?(:accounting_items)

    create_table :accounting_items do |t|
      t.references :company, foreign_key: true, type: :bigint
      t.string :code
      t.string :name
      t.string :sub_code
      t.string :sub_name
      t.integer :disp_level
      t.boolean :hidden, default: false
      t.integer :debit_tax_type, limit: 2
      t.integer :credit_tax_type, limit: 2
      t.integer :tax_autocalc, limit: 1
      t.integer :tax_rate, limit: 1

      t.timestamps
    end

    add_index :accounting_items, [:company_id, :code, :sub_code], unique: true, name: "index_accounting_items_on_company_id_and_code_and_sub_code"
  end
end
