class DropMstDetailDivisionAndStore < ActiveRecord::Migration[8.0]
  def change
    drop_table :"MST_DETAIL_DIVISION", if_exists: true
    drop_table :"MST_STORE", if_exists: true
  end
end
