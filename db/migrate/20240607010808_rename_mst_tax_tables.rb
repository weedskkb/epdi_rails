class RenameMstTaxTables < ActiveRecord::Migration[8.0]
  def up
    rename_table :"MST_TAX_CLASS", :tax_classes
    rename_table :"MST_TAX_RATE", :tax_rates

    rename_column :tax_classes, :"TAX_CLASS_NO", :id
    rename_column :tax_classes, :"TAX_CLASS_NAME", :name
    rename_column :tax_classes, :"DELETE_FLG", :delete_flg
    rename_column :tax_classes, :"CREATE_USER_ID", :created_by_id
    rename_column :tax_classes, :"CREATE_DATE", :created_at
    rename_column :tax_classes, :"UPDATE_USER_ID", :updated_by_id
    rename_column :tax_classes, :"UPDATE_DATE", :updated_at

    rename_column :tax_rates, :"TAX_RATE_NO", :id
    rename_column :tax_rates, :"TAX_RATE", :rate
    rename_column :tax_rates, :"DELETE_FLG", :delete_flg
    rename_column :tax_rates, :"CREATE_USER_ID", :created_by_id
    rename_column :tax_rates, :"CREATE_DATE", :created_at
    rename_column :tax_rates, :"UPDATE_USER_ID", :updated_by_id
    rename_column :tax_rates, :"UPDATE_DATE", :updated_at

    rename_column :"MST_CAPTURE_CATEGORY", :"TAX_CLASS_NO", :tax_class_id
    rename_column :"MST_CAPTURE_CATEGORY", :"TAX_RATE", :tax_rate_id

    rename_column :"TRN_CAPTURE_DATA", :"TAX_CLASS_NO", :tax_class_id
    rename_column :"TRN_CAPTURE_DATA", :"TAX_RATE_NO", :tax_rate_id

    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"DEBIT_TAX_CLASS_NO", :debit_tax_class_id
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"CREDIT_TAX_CLASS_NO", :credit_tax_class_id
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"DEBIT_TAX_RATE_NO", :debit_tax_rate_id
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :"CREDIT_TAX_RATE_NO", :credit_tax_rate_id

    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"DEBIT_TAX_CLASS", :debit_tax_class_id
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"CREDIT_TAX_CLASS", :credit_tax_class_id
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"DEBIT_TAX_RATE", :debit_tax_rate_id
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :"CREDIT_TAX_RATE", :credit_tax_rate_id
  end

  def down
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :credit_tax_rate_id, :"CREDIT_TAX_RATE"
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :debit_tax_rate_id, :"DEBIT_TAX_RATE"
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :credit_tax_class_id, :"CREDIT_TAX_CLASS"
    rename_column :"MST_JOURNAL_ENTRY_PATTERN", :debit_tax_class_id, :"DEBIT_TAX_CLASS"

    rename_column :"TRN_JOURNAL_ENTRY_DATA", :credit_tax_rate_id, :"CREDIT_TAX_RATE_NO"
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :debit_tax_rate_id, :"DEBIT_TAX_RATE_NO"
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :credit_tax_class_id, :"CREDIT_TAX_CLASS_NO"
    rename_column :"TRN_JOURNAL_ENTRY_DATA", :debit_tax_class_id, :"DEBIT_TAX_CLASS_NO"

    rename_column :"TRN_CAPTURE_DATA", :tax_rate_id, :"TAX_RATE_NO"
    rename_column :"TRN_CAPTURE_DATA", :tax_class_id, :"TAX_CLASS_NO"

    rename_column :"MST_CAPTURE_CATEGORY", :tax_rate_id, :"TAX_RATE"
    rename_column :"MST_CAPTURE_CATEGORY", :tax_class_id, :"TAX_CLASS_NO"

    rename_column :tax_rates, :updated_at, :"UPDATE_DATE"
    rename_column :tax_rates, :updated_by_id, :"UPDATE_USER_ID"
    rename_column :tax_rates, :created_at, :"CREATE_DATE"
    rename_column :tax_rates, :created_by_id, :"CREATE_USER_ID"
    rename_column :tax_rates, :delete_flg, :"DELETE_FLG"
    rename_column :tax_rates, :rate, :"TAX_RATE"
    rename_column :tax_rates, :id, :"TAX_RATE_NO"

    rename_column :tax_classes, :updated_at, :"UPDATE_DATE"
    rename_column :tax_classes, :updated_by_id, :"UPDATE_USER_ID"
    rename_column :tax_classes, :created_at, :"CREATE_DATE"
    rename_column :tax_classes, :created_by_id, :"CREATE_USER_ID"
    rename_column :tax_classes, :delete_flg, :"DELETE_FLG"
    rename_column :tax_classes, :name, :"TAX_CLASS_NAME"
    rename_column :tax_classes, :id, :"TAX_CLASS_NO"

    rename_table :tax_rates, :"MST_TAX_RATE"
    rename_table :tax_classes, :"MST_TAX_CLASS"
  end
end
