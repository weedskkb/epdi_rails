class DropMstAuthorityAndUserStatus < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :users, name: :fk_users_status, if_exists: true
    remove_foreign_key :users, name: :fk_users_authority, if_exists: true

    drop_table :"MST_AUTHOLITY", if_exists: true
    drop_table :"MST_USER_STATUS", if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "MST_AUTHOLITY and MST_USER_STATUS tables cannot be restored automatically"
  end
end
