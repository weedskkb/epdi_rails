class RenameTrnUserToUsers < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :"TRN_USER", column: "AUTHOLITY_NO"
    remove_foreign_key :"TRN_USER", column: "STATUS_NO"
    remove_foreign_key :"TRN_USER", name: "FK_TRN_USER_TRN_USER_CREATE_USER_ID"
    remove_foreign_key :"TRN_USER", name: "FK_TRN_USER_TRN_USER_UPDATE_USER_ID"

    rename_table :"TRN_USER", :users

    rename_column :users, :"USER_ID", :id
    rename_column :users, :"USER_NAME", :user_name
    rename_column :users, :"LOGIN_ID", :login_id
    rename_column :users, :"PASS_WORD", :password_digest
    rename_column :users, :"SALT", :salt
    rename_column :users, :"AUTHOLITY_NO", :authority_id
    rename_column :users, :"STATUS_NO", :status_id
    rename_column :users, :"CREATE_USER_ID", :created_by_id
    rename_column :users, :"CREATE_DATE", :created_at
    rename_column :users, :"UPDATE_USER_ID", :updated_by_id
    rename_column :users, :"UPDATE_DATE", :updated_at
    rename_column :users, :"DELETE_FLG", :delete_flg

    rename_index :users, :"FK_TRN_USER_TRN_USER_CREATE_USER_ID", :index_users_on_created_by_id
    rename_index :users, :"FK_TRN_USER_TRN_USER_UPDATE_USER_ID", :index_users_on_updated_by_id

    add_foreign_key :users, :"MST_AUTHOLITY", column: :authority_id, primary_key: "AUTHOLITY_NO", name: :fk_users_authority
    add_foreign_key :users, :"MST_USER_STATUS", column: :status_id, primary_key: "STATUS_NO", name: :fk_users_status
    add_foreign_key :users, :users, column: :created_by_id, primary_key: :id, name: :fk_users_created_by
    add_foreign_key :users, :users, column: :updated_by_id, primary_key: :id, name: :fk_users_updated_by
  end

  def down
    remove_foreign_key :users, name: :fk_users_updated_by
    remove_foreign_key :users, name: :fk_users_created_by
    remove_foreign_key :users, name: :fk_users_status
    remove_foreign_key :users, name: :fk_users_authority

    rename_index :users, :index_users_on_updated_by_id, :"FK_TRN_USER_TRN_USER_UPDATE_USER_ID"
    rename_index :users, :index_users_on_created_by_id, :"FK_TRN_USER_TRN_USER_CREATE_USER_ID"

    rename_column :users, :delete_flg, :"DELETE_FLG"
    rename_column :users, :updated_at, :"UPDATE_DATE"
    rename_column :users, :updated_by_id, :"UPDATE_USER_ID"
    rename_column :users, :created_at, :"CREATE_DATE"
    rename_column :users, :created_by_id, :"CREATE_USER_ID"
    rename_column :users, :status_id, :"STATUS_NO"
    rename_column :users, :authority_id, :"AUTHOLITY_NO"
    rename_column :users, :salt, :"SALT"
    rename_column :users, :password_digest, :"PASS_WORD"
    rename_column :users, :login_id, :"LOGIN_ID"
    rename_column :users, :user_name, :"USER_NAME"
    rename_column :users, :id, :"USER_ID"

    rename_table :users, :"TRN_USER"

    add_foreign_key :"TRN_USER", :"TRN_USER", column: "UPDATE_USER_ID", primary_key: "USER_ID", name: "FK_TRN_USER_TRN_USER_UPDATE_USER_ID"
    add_foreign_key :"TRN_USER", :"TRN_USER", column: "CREATE_USER_ID", primary_key: "USER_ID", name: "FK_TRN_USER_TRN_USER_CREATE_USER_ID"
    add_foreign_key :"TRN_USER", :"MST_USER_STATUS", column: "STATUS_NO", primary_key: "STATUS_NO"
    add_foreign_key :"TRN_USER", :"MST_AUTHOLITY", column: "AUTHOLITY_NO", primary_key: "AUTHOLITY_NO"
  end
end
