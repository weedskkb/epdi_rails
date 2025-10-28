class CreateBusinessConnections < ActiveRecord::Migration[8.0]
  def change
    create_table :business_connections do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.boolean :hidden, null: false, default: false
      t.references :created_by, foreign_key: { to_table: :users }, type: :integer
      t.references :updated_by, foreign_key: { to_table: :users }, type: :integer

      t.timestamps
    end
  end
end
