class RenameMstCompanyToCompanies < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :"MST_DEPARTMENT", name: "FK_MST_DEPARTMENT_MST_COMPANY_COMPANY_NO", if_exists: true
    remove_foreign_key :"MST_DEPARTMENT", column: "COMPANY_NO", if_exists: true

    rename_table :"MST_COMPANY", :companies

    rename_column :companies, :"COMPANY_NO", :id
    rename_column :companies, :"COMPANY_NAME", :name
    rename_column :companies, :"DELETE_FLG", :delete_flg
    rename_column :companies, :"CREATE_USER_ID", :created_by_id
    rename_column :companies, :"CREATE_DATE", :created_at
    rename_column :companies, :"UPDATE_USER_ID", :updated_by_id
    rename_column :companies, :"UPDATE_DATE", :updated_at

    rename_column :"MST_DEPARTMENT", :"COMPANY_NO", :company_id
    rename_index :"MST_DEPARTMENT", :"IX_MST_DEPARTMENT_COMPANY_NO", :index_mst_department_on_company_id

    rename_column :"MST_STORE", :"COMPANY_NO", :company_id if column_exists?(:"MST_STORE", :"COMPANY_NO")
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"COMPANY_NO", :company_id if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :"COMPANY_NO")
    rename_column :"TRN_CAPTURE_DATA", :"COMPANY_NO", :company_id if column_exists?(:"TRN_CAPTURE_DATA", :"COMPANY_NO")
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"COMPANY_NO", :company_id if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :"COMPANY_NO")
    rename_column :"MST_CAPTURE_CATEGORY", :"SUPPLIER_COMPANY_NO", :supplier_company_id if column_exists?(:"MST_CAPTURE_CATEGORY", :"SUPPLIER_COMPANY_NO")

    add_foreign_key :"MST_DEPARTMENT", :companies, column: :company_id, primary_key: :id, name: :fk_mst_department_company, on_delete: :cascade
  end

  def down
    remove_foreign_key :"MST_DEPARTMENT", name: :fk_mst_department_company

    rename_index :"MST_DEPARTMENT", :index_mst_department_on_company_id, :"IX_MST_DEPARTMENT_COMPANY_NO"
    rename_column :"MST_DEPARTMENT", :company_id, :"COMPANY_NO"

    rename_column :"MST_CAPTURE_CATEGORY", :supplier_company_id, :"SUPPLIER_COMPANY_NO" if column_exists?(:"MST_CAPTURE_CATEGORY", :supplier_company_id)
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :company_id, :"COMPANY_NO" if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :company_id)
    rename_column :"TRN_CAPTURE_DATA", :company_id, :"COMPANY_NO" if column_exists?(:"TRN_CAPTURE_DATA", :company_id)
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :company_id, :"COMPANY_NO" if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :company_id)
    rename_column :"MST_STORE", :company_id, :"COMPANY_NO" if column_exists?(:"MST_STORE", :company_id)

    rename_column :companies, :updated_at, :"UPDATE_DATE"
    rename_column :companies, :updated_by_id, :"UPDATE_USER_ID"
    rename_column :companies, :created_at, :"CREATE_DATE"
    rename_column :companies, :created_by_id, :"CREATE_USER_ID"
    rename_column :companies, :delete_flg, :"DELETE_FLG"
    rename_column :companies, :name, :"COMPANY_NAME"
    rename_column :companies, :id, :"COMPANY_NO"

    rename_table :companies, :"MST_COMPANY"

    add_foreign_key :"MST_DEPARTMENT", :"MST_COMPANY", column: "COMPANY_NO", primary_key: "COMPANY_NO"
    add_foreign_key :"MST_DEPARTMENT", :"MST_COMPANY", column: "COMPANY_NO", primary_key: "COMPANY_NO", name: "FK_MST_DEPARTMENT_MST_COMPANY_COMPANY_NO", on_delete: :cascade
  end
end
