class RenameMstSupplierToSuppliers < ActiveRecord::Migration[8.0]
  def up
    rename_table :"MST_SUPPLIER", :suppliers

    rename_column :suppliers, :"SUPPLIER_NO", :id
    rename_column :suppliers, :"SUPPLIER_NAME", :name
    rename_column :suppliers, :"DELETE_FLG", :delete_flg
    rename_column :suppliers, :"CREATE_USER_ID", :created_by_id
    rename_column :suppliers, :"CREATE_DATE", :created_at
    rename_column :suppliers, :"UPDATE_USER_ID", :updated_by_id
    rename_column :suppliers, :"UPDATE_DATE", :updated_at
  end

  def down
    rename_column :suppliers, :updated_at, :"UPDATE_DATE"
    rename_column :suppliers, :updated_by_id, :"UPDATE_USER_ID"
    rename_column :suppliers, :created_at, :"CREATE_DATE"
    rename_column :suppliers, :created_by_id, :"CREATE_USER_ID"
    rename_column :suppliers, :delete_flg, :"DELETE_FLG"
    rename_column :suppliers, :name, :"SUPPLIER_NAME"
    rename_column :suppliers, :id, :"SUPPLIER_NO"

    rename_table :suppliers, :"MST_SUPPLIER"
  end
end
