class RenameSupplierForeignKeys < ActiveRecord::Migration[8.0]
  def up
    rename_column :"MST_CAPTURE_CATEGORY", :"SUPPLIER_NO", :supplier_id
    rename_column :"MST_COMPANY", :"SUPPLIER_NO", :supplier_id
    rename_column :"TRN_CAPTURE_DATA", :"SUPPLIER_NO", :supplier_id
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"DEBIT_SUPPLIER_NO", :debit_supplier_id
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"CREDIT_SUPPLIER_NO", :credit_supplier_id
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"DEBIT_SUPPLIER_NO", :debit_supplier_id
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"CREDIT_SUPPLIER_NO", :credit_supplier_id
  end

  def down
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :credit_supplier_id, :"CREDIT_SUPPLIER_NO"
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :debit_supplier_id, :"DEBIT_SUPPLIER_NO"
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :credit_supplier_id, :"CREDIT_SUPPLIER_NO"
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :debit_supplier_id, :"DEBIT_SUPPLIER_NO"
    rename_column :"TRN_CAPTURE_DATA", :supplier_id, :"SUPPLIER_NO"
    rename_column :"MST_COMPANY", :supplier_id, :"SUPPLIER_NO"
    rename_column :"MST_CAPTURE_CATEGORY", :supplier_id, :"SUPPLIER_NO"
  end
end
