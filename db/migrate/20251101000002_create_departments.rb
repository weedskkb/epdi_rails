class CreateDepartments < ActiveRecord::Migration[8.0]
  def change
    create_table :departments do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :store_code, null: false
      t.string :store_name, null: false
      t.boolean :hidden, null: false, default: false
      t.integer :company_id

      t.timestamps
    end
    add_index :departments, :code, unique: true
    add_index :departments, :store_code, unique: true
  end
end
