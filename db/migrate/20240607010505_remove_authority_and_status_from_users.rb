class RemoveAuthorityAndStatusFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :authority_id, :integer
    remove_column :users, :status_id, :integer
  end
end
