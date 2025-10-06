# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_06_01_000000) do
  create_table "MST_ACCOUNT", primary_key: "ACCOUNT_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "ACCOUNT_NAME", null: false
    t.boolean "DELETE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
  end

  create_table "MST_AUTHOLITY", primary_key: "AUTHOLITY_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "AUTHOLITY_NAME", null: false
    t.boolean "DELETE_FLG", default: false, null: false
  end

  create_table "MST_CAPTURE_CATEGORY", primary_key: "CAPTURE_CATEGORY_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "CAPTURE_CATEGORY_NAME", null: false
    t.integer "TAX_CLASS_NO"
    t.integer "TAX_RATE"
    t.integer "SUPPLIER_NO"
    t.integer "SUPPLIER_COMPANY_NO"
    t.integer "DEBIT_DEPARTMENT_NO"
    t.integer "DEBIT_ACCOUNT_NO"
    t.integer "DEBIT_SUB_ACCOUNT_NO"
    t.integer "CREDIT_DEPARTMENT_NO"
    t.integer "CREDIT_ACCOUNT_NO"
    t.integer "CREDIT_SUB_ACCOUNT_NO"
    t.string "ABSTRACT"
    t.string "SUPPLIER_ABSTRACT"
    t.integer "JOURNAL_ENTRY_PATTERN_GROUP_NO", null: false
    t.integer "PAYMENT_TERMS"
    t.boolean "DELETE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
  end

  create_table "MST_COMPANY", primary_key: "COMPANY_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "COMPANY_NAME", null: false
    t.integer "SUPPLIER_NO"
    t.boolean "DELETE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
  end

  create_table "MST_DEPARTMENT", primary_key: "DEPARTMENT_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "DEPARTMENT_NAME", null: false
    t.integer "COMPANY_NO", null: false
    t.boolean "DELETE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
    t.index ["COMPANY_NO"], name: "IX_MST_DEPARTMENT_COMPANY_NO"
  end

  create_table "MST_DETAIL_DIVISION", primary_key: "DETAIL_DIVISION_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "DETAIL_DIVISION_NAME", null: false
    t.boolean "DELETE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
  end

  create_table "MST_JOURNAL_ENTRY_PATTERN", primary_key: "JOURNAL_ENTRY_PATTERN_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "JOURNAL_ENTRY_PATTERN_GROUP_NO", null: false
    t.string "JOURNAL_ENTRY_PATTERN_NAME", null: false
    t.integer "ROW_NO", null: false
    t.integer "DATE_PATTERN_NO", null: false
    t.integer "COMPANY_NO"
    t.integer "DEBIT_DEPARTMENT_NO"
    t.integer "DEBIT_ACCOUNT_NO"
    t.integer "DEBIT_SUB_ACCOUNT_NO"
    t.integer "DEBIT_SUPPLIER_NO"
    t.integer "DEBIT_TAX_RATE"
    t.integer "DEBIT_TAX_CLASS"
    t.integer "CREDIT_DEPARTMENT_NO"
    t.integer "CREDIT_ACCOUNT_NO"
    t.integer "CREDIT_SUB_ACCOUNT_NO"
    t.integer "CREDIT_SUPPLIER_NO"
    t.integer "CREDIT_TAX_RATE"
    t.integer "CREDIT_TAX_CLASS"
    t.boolean "FIXED_AMOUNT_FLG", default: false, null: false
    t.integer "FIXED_AMOUNT"
    t.boolean "FILTER_RATIO_FLG", default: false, null: false
    t.integer "FILTER_RATIO"
    t.boolean "FILTER_AMOUNT_FLG", default: false, null: false
    t.integer "FILTER_AMOUNT"
    t.integer "DETAIL_DIVISION_NO"
    t.boolean "INCLUDE_TAX_FLG", default: false, null: false
    t.boolean "TAX_CALC_FLG", default: false, null: false
    t.boolean "ACCURE_FLG", default: false, null: false
    t.boolean "DELETE_FLG", default: false, null: false
    t.string "ABSTRACT"
    t.integer "CREATE_USER_ID"
    t.integer "UPDATE_USER_ID"
    t.datetime "CREATE_DATE", null: false
    t.datetime "UPDATE_DATE"
  end

  create_table "MST_STORE", primary_key: "STORE_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "STORE_NAME", null: false
    t.boolean "DELETE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
    t.integer "COMPANY_NO"
  end

  create_table "MST_SUB_ACCOUNT", primary_key: "ID", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "SUB_ACCOUNT_NO", null: false
    t.string "SUB_ACCOUNT_NAME", null: false
    t.integer "ACCOUNT_NO", null: false
    t.boolean "DELETE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
    t.index ["ACCOUNT_NO", "SUB_ACCOUNT_NO"], name: "IX_MST_SUB_ACCOUNT_ACCOUNT_NO", unique: true
  end

  create_table "MST_SUPPLIER", primary_key: "SUPPLIER_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "SUPPLIER_NAME", null: false
    t.boolean "DELETE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
  end

  create_table "MST_TAX_CLASS", primary_key: "TAX_CLASS_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "TAX_CLASS_NAME", null: false
    t.boolean "DELETE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
  end

  create_table "MST_TAX_RATE", primary_key: "TAX_RATE_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "TAX_RATE", null: false
    t.boolean "DELETE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
  end

  create_table "MST_USER_STATUS", primary_key: "STATUS_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "STATUS_NAME", null: false
    t.boolean "DELETE_FLG", default: false, null: false
  end

  create_table "TRN_CAPTURE_DATA", primary_key: "CAPTURE_DATA_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "CAPTURE_HISTORY_NO", null: false
    t.integer "ROW_NO", null: false
    t.integer "COMPANY_NO", null: false
    t.integer "DEPARTMENT_NO", null: false
    t.integer "SUPPLIER_NO"
    t.integer "ACCOUNT_NO"
    t.integer "SUB_ACCOUNT_NO"
    t.integer "AMMOUNT", null: false
    t.integer "SECOND_AMMOUNT", null: false
    t.integer "TAX_CLASS_NO"
    t.integer "TAX_RATE_NO"
    t.datetime "CREATE_DATE", null: false
    t.integer "CREATE_USER_ID", null: false
    t.string "LIST_CD"
    t.index ["CAPTURE_HISTORY_NO"], name: "fk_rails_8171a22b36"
    t.index ["DEPARTMENT_NO"], name: "fk_rails_f543574a4f"
  end

  create_table "TRN_CAPTURE_HISTORY", primary_key: "CAPTURE_HISTORY_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "CAPTURE_CATEGORY_NO", null: false
    t.date "ACCRUAL_MONTH"
    t.date "PAYMENT_MONTH"
    t.boolean "LOCK_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
  end

  create_table "TRN_JOURNAL_ENTRY_DATA", primary_key: "JOURNAL_ENTRY_DATA_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "JOURNAL_ENTRY_HISTORY_NO", null: false
    t.integer "EXCEL_ROW_NO", null: false
    t.integer "ROW_NO", null: false
    t.date "DATE", null: false
    t.integer "COMPANY_NO", null: false
    t.integer "DEPARTMENT_NO"
    t.integer "DEBIT_DEPARTMENT_NO"
    t.integer "DEBIT_ACCOUNT_NO"
    t.integer "DEBIT_SUB_ACCOUNT_NO"
    t.integer "DEBIT_AMMOUNT", null: false
    t.integer "DEBIT_TAX_CLASS_NO"
    t.integer "DEBIT_TAX_RATE_NO"
    t.integer "DEBIT_SUPPLIER_NO"
    t.integer "CREDIT_DEPARTMENT_NO"
    t.integer "CREDIT_ACCOUNT_NO"
    t.integer "CREDIT_SUB_ACCOUNT_NO"
    t.integer "CREDIT_AMMOUNT", null: false
    t.integer "CREDIT_TAX_CLASS_NO"
    t.integer "CREDIT_TAX_RATE_NO"
    t.integer "CREDIT_SUPPLIER_NO"
    t.string "ABSTRACT"
    t.datetime "CREATE_DATE", null: false
    t.integer "CREATE_USER_ID", null: false
  end

  create_table "TRN_JOURNAL_ENTRY_HISTORY", primary_key: "JOURNAL_ENTRY_HISTORY_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "CAPTURE_HISTORY_NO", null: false
    t.integer "CAPTURE_CATEGORY_NO", null: false
    t.date "ACCRUAL_MONTH", null: false
    t.date "PAYMENT_MONTH", null: false
    t.boolean "EXECUTE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.index ["CAPTURE_CATEGORY_NO"], name: "fk_rails_98e1ec1471"
  end

  create_table "TRN_USER", primary_key: "USER_ID", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "USER_NAME", limit: 12
    t.string "LOGIN_ID", limit: 15
    t.string "PASS_WORD"
    t.binary "SALT"
    t.integer "AUTHOLITY_NO", null: false
    t.integer "STATUS_NO", null: false
    t.integer "CREATE_USER_ID"
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
    t.boolean "DELETE_FLG", default: false, null: false
    t.index ["AUTHOLITY_NO"], name: "fk_rails_380375b7f7"
    t.index ["STATUS_NO"], name: "fk_rails_25251f7098"
  end

  add_foreign_key "MST_DEPARTMENT", "MST_COMPANY", column: "COMPANY_NO", primary_key: "COMPANY_NO"
  add_foreign_key "MST_SUB_ACCOUNT", "MST_ACCOUNT", column: "ACCOUNT_NO", primary_key: "ACCOUNT_NO"
  add_foreign_key "TRN_CAPTURE_DATA", "MST_DEPARTMENT", column: "DEPARTMENT_NO", primary_key: "DEPARTMENT_NO"
  add_foreign_key "TRN_CAPTURE_DATA", "TRN_CAPTURE_HISTORY", column: "CAPTURE_HISTORY_NO", primary_key: "CAPTURE_HISTORY_NO"
  add_foreign_key "TRN_JOURNAL_ENTRY_HISTORY", "MST_CAPTURE_CATEGORY", column: "CAPTURE_CATEGORY_NO", primary_key: "CAPTURE_CATEGORY_NO"
  add_foreign_key "TRN_USER", "MST_AUTHOLITY", column: "AUTHOLITY_NO", primary_key: "AUTHOLITY_NO"
  add_foreign_key "TRN_USER", "MST_USER_STATUS", column: "STATUS_NO", primary_key: "STATUS_NO"
end
