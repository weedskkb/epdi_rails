class RenameMstAccountTables < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :"MST_SUB_ACCOUNT", column: "ACCOUNT_NO", if_exists: true

    rename_table :"MST_ACCOUNT", :accounts
    rename_table :"MST_SUB_ACCOUNT", :sub_accounts

    rename_column :accounts, :"ACCOUNT_NO", :id
    rename_column :accounts, :"ACCOUNT_NAME", :name
    rename_column :accounts, :"ACCOUNT_NAME_KANA", :kana if column_exists?(:accounts, :"ACCOUNT_NAME_KANA")
    rename_column :accounts, :"DELETE_FLG", :delete_flg
    rename_column :accounts, :"CREATE_USER_ID", :created_by_id
    rename_column :accounts, :"CREATE_DATE", :created_at
    rename_column :accounts, :"UPDATE_USER_ID", :updated_by_id
    rename_column :accounts, :"UPDATE_DATE", :updated_at
    add_column :accounts, :code, :integer unless column_exists?(:accounts, :code)

    rename_column :sub_accounts, :"ID", :id if column_exists?(:sub_accounts, :"ID")
    rename_column :sub_accounts, :"SUB_ACCOUNT_NO", :sub_code
    rename_column :sub_accounts, :"SUB_ACCOUNT_NAME", :name
    rename_column :sub_accounts, :"ACCOUNT_NO", :code
    rename_column :sub_accounts, :"DELETE_FLG", :delete_flg
    rename_column :sub_accounts, :"CREATE_USER_ID", :created_by_id
    rename_column :sub_accounts, :"CREATE_DATE", :created_at
    rename_column :sub_accounts, :"UPDATE_USER_ID", :updated_by_id
    rename_column :sub_accounts, :"UPDATE_DATE", :updated_at

    if index_name_exists?(:sub_accounts, "IX_MST_SUB_ACCOUNT_ACCOUNT_NO")
      rename_index :sub_accounts, "IX_MST_SUB_ACCOUNT_ACCOUNT_NO", :index_sub_accounts_on_code_and_sub_code
    end

    add_foreign_key :sub_accounts, :accounts, column: :code, primary_key: :id
  end

  def down
    remove_foreign_key :sub_accounts, column: :code, if_exists: true

    rename_column :sub_accounts, :code, :"ACCOUNT_NO"
    rename_column :sub_accounts, :name, :"SUB_ACCOUNT_NAME"
    rename_column :sub_accounts, :sub_code, :"SUB_ACCOUNT_NO"
    rename_column :sub_accounts, :id, :"ID" if column_exists?(:sub_accounts, :id)

    rename_column :sub_accounts, :updated_at, :"UPDATE_DATE"
    rename_column :sub_accounts, :updated_by_id, :"UPDATE_USER_ID"
    rename_column :sub_accounts, :created_at, :"CREATE_DATE"
    rename_column :sub_accounts, :created_by_id, :"CREATE_USER_ID"
    rename_column :sub_accounts, :delete_flg, :"DELETE_FLG"
    remove_column :accounts, :code, if_exists: true
    rename_column :accounts, :updated_at, :"UPDATE_DATE"
    rename_column :accounts, :updated_by_id, :"UPDATE_USER_ID"
    rename_column :accounts, :created_at, :"CREATE_DATE"
    rename_column :accounts, :created_by_id, :"CREATE_USER_ID"
    rename_column :accounts, :delete_flg, :"DELETE_FLG"
    rename_column :accounts, :name, :"ACCOUNT_NAME"
    rename_column :accounts, :kana, :"ACCOUNT_NAME_KANA" if column_exists?(:accounts, :kana)
    rename_column :accounts, :id, :"ACCOUNT_NO"

    rename_table :sub_accounts, :"MST_SUB_ACCOUNT"
    rename_table :accounts, :"MST_ACCOUNT"

    if index_name_exists?(:"MST_SUB_ACCOUNT", :index_sub_accounts_on_code_and_sub_code)
      rename_index :"MST_SUB_ACCOUNT", :index_sub_accounts_on_code_and_sub_code, "IX_MST_SUB_ACCOUNT_ACCOUNT_NO"
    end

    add_foreign_key :"MST_SUB_ACCOUNT", :"MST_ACCOUNT", column: "ACCOUNT_NO", primary_key: "ACCOUNT_NO"
  end
end
