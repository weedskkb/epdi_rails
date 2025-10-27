class NormalizeJournalEntryPatternsTable < ActiveRecord::Migration[8.0]
  def up
    rename_table :"MST_JOURNAL_ENTRY_PATTERN", :journal_entry_patterns

    rename_column :journal_entry_patterns, :"JOURNAL_ENTRY_PATTERN_NO", :id
    rename_column :journal_entry_patterns, :"JOURNAL_ENTRY_PATTERN_GROUP_NO", :group_no
    rename_column :journal_entry_patterns, :"JOURNAL_ENTRY_PATTERN_NAME", :name
    rename_column :journal_entry_patterns, :"ROW_NO", :row_no
    rename_column :journal_entry_patterns, :"DATE_PATTERN_NO", :date_pattern_no
    rename_column :journal_entry_patterns, :"FIXED_AMOUNT_FLG", :fixed_amount_flag
    rename_column :journal_entry_patterns, :"FIXED_AMOUNT", :fixed_amount
    rename_column :journal_entry_patterns, :"FILTER_RATIO_FLG", :filter_ratio_flag
    rename_column :journal_entry_patterns, :"FILTER_RATIO", :filter_ratio
    rename_column :journal_entry_patterns, :"FILTER_AMOUNT_FLG", :filter_amount_flag
    rename_column :journal_entry_patterns, :"FILTER_AMOUNT", :filter_amount
    rename_column :journal_entry_patterns, :"DETAIL_DIVISION_NO", :detail_division_no
    rename_column :journal_entry_patterns, :"INCLUDE_TAX_FLG", :include_tax_flag
    rename_column :journal_entry_patterns, :"TAX_CALC_FLG", :tax_calc_flag
    rename_column :journal_entry_patterns, :"ACCURE_FLG", :accure_flag
    rename_column :journal_entry_patterns, :"DELETE_FLG", :delete_flg
    rename_column :journal_entry_patterns, :"ABSTRACT", :abstract
    rename_column :journal_entry_patterns, :"CREATE_USER_ID", :created_by_id
    rename_column :journal_entry_patterns, :"UPDATE_USER_ID", :updated_by_id
    rename_column :journal_entry_patterns, :"CREATE_DATE", :created_at
    rename_column :journal_entry_patterns, :"UPDATE_DATE", :updated_at
  end

  def down
    rename_column :journal_entry_patterns, :id, :"JOURNAL_ENTRY_PATTERN_NO"
    rename_column :journal_entry_patterns, :group_no, :"JOURNAL_ENTRY_PATTERN_GROUP_NO"
    rename_column :journal_entry_patterns, :name, :"JOURNAL_ENTRY_PATTERN_NAME"
    rename_column :journal_entry_patterns, :row_no, :"ROW_NO"
    rename_column :journal_entry_patterns, :date_pattern_no, :"DATE_PATTERN_NO"
    rename_column :journal_entry_patterns, :fixed_amount_flag, :"FIXED_AMOUNT_FLG"
    rename_column :journal_entry_patterns, :fixed_amount, :"FIXED_AMOUNT"
    rename_column :journal_entry_patterns, :filter_ratio_flag, :"FILTER_RATIO_FLG"
    rename_column :journal_entry_patterns, :filter_ratio, :"FILTER_RATIO"
    rename_column :journal_entry_patterns, :filter_amount_flag, :"FILTER_AMOUNT_FLG"
    rename_column :journal_entry_patterns, :filter_amount, :"FILTER_AMOUNT"
    rename_column :journal_entry_patterns, :detail_division_no, :"DETAIL_DIVISION_NO"
    rename_column :journal_entry_patterns, :include_tax_flag, :"INCLUDE_TAX_FLG"
    rename_column :journal_entry_patterns, :tax_calc_flag, :"TAX_CALC_FLG"
    rename_column :journal_entry_patterns, :accure_flag, :"ACCURE_FLG"
    rename_column :journal_entry_patterns, :delete_flg, :"DELETE_FLG"
    rename_column :journal_entry_patterns, :abstract, :"ABSTRACT"
    rename_column :journal_entry_patterns, :created_by_id, :"CREATE_USER_ID"
    rename_column :journal_entry_patterns, :updated_by_id, :"UPDATE_USER_ID"
    rename_column :journal_entry_patterns, :created_at, :"CREATE_DATE"
    rename_column :journal_entry_patterns, :updated_at, :"UPDATE_DATE"

    rename_table :journal_entry_patterns, :"MST_JOURNAL_ENTRY_PATTERN"
  end
end
