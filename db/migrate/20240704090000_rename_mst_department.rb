class RenameMstDepartment < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :"MST_DEPARTMENT", name: :fk_mst_department_company, if_exists: true
    remove_foreign_key :"TRN_CAPTURE_DATA", column: "DEPARTMENT_NO", if_exists: true
    remove_index :"TRN_CAPTURE_DATA", name: "fk_rails_f543574a4f", if_exists: true

    rename_table :"MST_DEPARTMENT", :departments

    rename_column :departments, :"DEPARTMENT_NO", :id
    rename_column :departments, :"DEPARTMENT_NAME", :name
    rename_column :departments, :"DELETE_FLG", :delete_flg
    rename_column :departments, :"CREATE_USER_ID", :created_by_id
    rename_column :departments, :"CREATE_DATE", :created_at
    rename_column :departments, :"UPDATE_USER_ID", :updated_by_id
    rename_column :departments, :"UPDATE_DATE", :updated_at
    rename_index :departments, :index_mst_department_on_company_id, :index_departments_on_company_id if index_exists?(:departments, :company_id, name: :index_mst_department_on_company_id)

    rename_column :"MST_CAPTURE_CATEGORY", :"DEBIT_DEPARTMENT_NO", :debit_department_id if column_exists?(:"MST_CAPTURE_CATEGORY", :"DEBIT_DEPARTMENT_NO")
    rename_column :"MST_CAPTURE_CATEGORY", :"CREDIT_DEPARTMENT_NO", :credit_department_id if column_exists?(:"MST_CAPTURE_CATEGORY", :"CREDIT_DEPARTMENT_NO")

    rename_column :"TRN_CAPTURE_DATA", :"DEPARTMENT_NO", :department_id if column_exists?(:"TRN_CAPTURE_DATA", :"DEPARTMENT_NO")

    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"DEPARTMENT_NO", :department_id if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :"DEPARTMENT_NO")
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"DEBIT_DEPARTMENT_NO", :debit_department_id if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :"DEBIT_DEPARTMENT_NO")
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"CREDIT_DEPARTMENT_NO", :credit_department_id if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :"CREDIT_DEPARTMENT_NO")

    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"DEBIT_DEPARTMENT_NO", :debit_department_id if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :"DEBIT_DEPARTMENT_NO")
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"CREDIT_DEPARTMENT_NO", :credit_department_id if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :"CREDIT_DEPARTMENT_NO")

    add_index :"TRN_CAPTURE_DATA", :department_id, name: :index_trn_capture_data_on_department_id unless index_exists?(:"TRN_CAPTURE_DATA", :department_id, name: :index_trn_capture_data_on_department_id)
    add_foreign_key :departments, :companies, column: :company_id, primary_key: :id, name: :fk_departments_company, on_delete: :cascade
    add_foreign_key :"TRN_CAPTURE_DATA", :departments, column: :department_id, primary_key: :id
  end

  def down
    remove_foreign_key :"TRN_CAPTURE_DATA", :departments if foreign_key_exists?(:"TRN_CAPTURE_DATA", :departments)
    remove_foreign_key :departments, name: :fk_departments_company if foreign_key_exists?(:departments, name: :fk_departments_company)
    remove_index :"TRN_CAPTURE_DATA", name: :index_trn_capture_data_on_department_id, if_exists: true

    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :credit_department_id, :"CREDIT_DEPARTMENT_NO" if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :credit_department_id)
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :debit_department_id, :"DEBIT_DEPARTMENT_NO" if column_exists?(:"MST_JOURNAL_ENTRY_PATTERN", :debit_department_id)

    rename_column :"TRN_JOURNAL_ENTRY_DATA", :credit_department_id, :"CREDIT_DEPARTMENT_NO" if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :credit_department_id)
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :debit_department_id, :"DEBIT_DEPARTMENT_NO" if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :debit_department_id)
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :department_id, :"DEPARTMENT_NO" if column_exists?(:"TRN_JOURNAL_ENTRY_DATA", :department_id)

    rename_column :"TRN_CAPTURE_DATA", :department_id, :"DEPARTMENT_NO" if column_exists?(:"TRN_CAPTURE_DATA", :department_id)

    rename_column :"MST_CAPTURE_CATEGORY", :credit_department_id, :"CREDIT_DEPARTMENT_NO" if column_exists?(:"MST_CAPTURE_CATEGORY", :credit_department_id)
    rename_column :"MST_CAPTURE_CATEGORY", :debit_department_id, :"DEBIT_DEPARTMENT_NO" if column_exists?(:"MST_CAPTURE_CATEGORY", :debit_department_id)

    rename_index :departments, :index_departments_on_company_id, :index_mst_department_on_company_id if index_exists?(:departments, :company_id, name: :index_departments_on_company_id)
    rename_column :departments, :updated_at, :"UPDATE_DATE"
    rename_column :departments, :updated_by_id, :"UPDATE_USER_ID"
    rename_column :departments, :created_at, :"CREATE_DATE"
    rename_column :departments, :created_by_id, :"CREATE_USER_ID"
    rename_column :departments, :delete_flg, :"DELETE_FLG"
    rename_column :departments, :name, :"DEPARTMENT_NAME"
    rename_column :departments, :id, :"DEPARTMENT_NO"

    rename_table :departments, :"MST_DEPARTMENT"

    add_index :"TRN_CAPTURE_DATA", :"DEPARTMENT_NO", name: "fk_rails_f543574a4f" unless index_exists?(:"TRN_CAPTURE_DATA", :"DEPARTMENT_NO", name: "fk_rails_f543574a4f")
    add_foreign_key :"MST_DEPARTMENT", :companies, column: :company_id, primary_key: :id, name: :fk_mst_department_company, on_delete: :cascade
    add_foreign_key :"TRN_CAPTURE_DATA", :"MST_DEPARTMENT", column: "DEPARTMENT_NO", primary_key: "DEPARTMENT_NO"
  end
end
