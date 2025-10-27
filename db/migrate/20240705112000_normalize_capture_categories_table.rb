class NormalizeCaptureCategoriesTable < ActiveRecord::Migration[8.0]
  def up
    if foreign_key_exists?(:TRN_JOURNAL_ENTRY_HISTORY, :"MST_CAPTURE_CATEGORY", column: :"CAPTURE_CATEGORY_NO")
      remove_foreign_key :TRN_JOURNAL_ENTRY_HISTORY, column: :"CAPTURE_CATEGORY_NO"
    end

    rename_table :"MST_CAPTURE_CATEGORY", :capture_categories

    rename_column :capture_categories, :"CAPTURE_CATEGORY_NO", :id
    rename_column :capture_categories, :"CAPTURE_CATEGORY_NAME", :name
    rename_column :capture_categories, :"ABSTRACT", :abstract
    rename_column :capture_categories, :"SUPPLIER_ABSTRACT", :supplier_abstract
    rename_column :capture_categories, :"JOURNAL_ENTRY_PATTERN_GROUP_NO", :journal_entry_pattern_group_no
    rename_column :capture_categories, :"PAYMENT_TERMS", :payment_terms
    rename_column :capture_categories, :"DELETE_FLG", :delete_flg
    rename_column :capture_categories, :"CREATE_USER_ID", :created_by_id
    rename_column :capture_categories, :"CREATE_DATE", :created_at
    rename_column :capture_categories, :"UPDATE_USER_ID", :updated_by_id
    rename_column :capture_categories, :"UPDATE_DATE", :updated_at

    rename_column :"TRN_CAPTURE_HISTORY", :"CAPTURE_CATEGORY_NO", :capture_category_id
    rename_column :"TRN_JOURNAL_ENTRY_HISTORY", :"CAPTURE_CATEGORY_NO", :capture_category_id

    add_foreign_key :"TRN_CAPTURE_HISTORY", :capture_categories, column: :capture_category_id
    add_foreign_key :"TRN_JOURNAL_ENTRY_HISTORY", :capture_categories, column: :capture_category_id
  end

  def down
    remove_foreign_key :"TRN_CAPTURE_HISTORY", :capture_categories if foreign_key_exists?(:TRN_CAPTURE_HISTORY, :capture_categories)
    remove_foreign_key :"TRN_JOURNAL_ENTRY_HISTORY", :capture_categories if foreign_key_exists?(:TRN_JOURNAL_ENTRY_HISTORY, :capture_categories)

    rename_column :"TRN_CAPTURE_HISTORY", :capture_category_id, :"CAPTURE_CATEGORY_NO"
    rename_column :"TRN_JOURNAL_ENTRY_HISTORY", :capture_category_id, :"CAPTURE_CATEGORY_NO"

    rename_column :capture_categories, :id, :"CAPTURE_CATEGORY_NO"
    rename_column :capture_categories, :name, :"CAPTURE_CATEGORY_NAME"
    rename_column :capture_categories, :abstract, :"ABSTRACT"
    rename_column :capture_categories, :supplier_abstract, :"SUPPLIER_ABSTRACT"
    rename_column :capture_categories, :journal_entry_pattern_group_no, :"JOURNAL_ENTRY_PATTERN_GROUP_NO"
    rename_column :capture_categories, :payment_terms, :"PAYMENT_TERMS"
    rename_column :capture_categories, :delete_flg, :"DELETE_FLG"
    rename_column :capture_categories, :created_by_id, :"CREATE_USER_ID"
    rename_column :capture_categories, :created_at, :"CREATE_DATE"
    rename_column :capture_categories, :updated_by_id, :"UPDATE_USER_ID"
    rename_column :capture_categories, :updated_at, :"UPDATE_DATE"

    rename_table :capture_categories, :"MST_CAPTURE_CATEGORY"

    add_foreign_key :"TRN_JOURNAL_ENTRY_HISTORY", :"MST_CAPTURE_CATEGORY",
                    column: :"CAPTURE_CATEGORY_NO", primary_key: :"CAPTURE_CATEGORY_NO"
  end
end
