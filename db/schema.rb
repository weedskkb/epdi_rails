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

ActiveRecord::Schema[8.0].define(version: 2024_06_07_010505) do
  create_table "MST_ACCOUNT", primary_key: "ACCOUNT_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "ACCOUNT_NAME", null: false
    t.boolean "DELETE_FLG", default: false, null: false
    t.integer "CREATE_USER_ID", null: false
    t.datetime "CREATE_DATE", null: false
    t.integer "UPDATE_USER_ID"
    t.datetime "UPDATE_DATE"
  end

  create_table "MST_CAPTURE_CATEGORY", primary_key: "CAPTURE_CATEGORY_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "CAPTURE_CATEGORY_NAME", null: false
    t.integer "TAX_CLASS_NO"
    t.integer "TAX_RATE"
    t.integer "supplier_id"
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
    t.integer "supplier_id"
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
    t.integer "debit_supplier_id"
    t.integer "DEBIT_TAX_RATE"
    t.integer "DEBIT_TAX_CLASS"
    t.integer "CREDIT_DEPARTMENT_NO"
    t.integer "CREDIT_ACCOUNT_NO"
    t.integer "CREDIT_SUB_ACCOUNT_NO"
    t.integer "credit_supplier_id"
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

  create_table "TRN_CAPTURE_DATA", primary_key: "CAPTURE_DATA_NO", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "CAPTURE_HISTORY_NO", null: false
    t.integer "ROW_NO", null: false
    t.integer "COMPANY_NO", null: false
    t.integer "DEPARTMENT_NO", null: false
    t.integer "supplier_id"
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
    t.integer "DEBIT_AMMOUNT"
    t.integer "DEBIT_TAX_CLASS_NO"
    t.integer "DEBIT_TAX_RATE_NO"
    t.integer "debit_supplier_id"
    t.integer "CREDIT_DEPARTMENT_NO"
    t.integer "CREDIT_ACCOUNT_NO"
    t.integer "CREDIT_SUB_ACCOUNT_NO"
    t.integer "CREDIT_AMMOUNT"
    t.integer "CREDIT_TAX_CLASS_NO"
    t.integer "CREDIT_TAX_RATE_NO"
    t.integer "credit_supplier_id"
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

  create_table "suppliers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "delete_flg", default: false, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.integer "updated_by_id"
    t.datetime "updated_at"
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "user_name", limit: 12
    t.string "login_id", limit: 15
    t.string "password_digest"
    t.binary "salt"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.integer "updated_by_id"
    t.datetime "updated_at"
    t.boolean "delete_flg", default: false, null: false
    t.index ["created_by_id"], name: "index_users_on_created_by_id"
    t.index ["updated_by_id"], name: "index_users_on_updated_by_id"
  end

  add_foreign_key "MST_DEPARTMENT", "MST_COMPANY", column: "COMPANY_NO", primary_key: "COMPANY_NO"
  add_foreign_key "MST_DEPARTMENT", "MST_COMPANY", column: "COMPANY_NO", primary_key: "COMPANY_NO", name: "FK_MST_DEPARTMENT_MST_COMPANY_COMPANY_NO", on_delete: :cascade
  add_foreign_key "MST_SUB_ACCOUNT", "MST_ACCOUNT", column: "ACCOUNT_NO", primary_key: "ACCOUNT_NO"
  add_foreign_key "MST_SUB_ACCOUNT", "MST_ACCOUNT", column: "ACCOUNT_NO", primary_key: "ACCOUNT_NO", name: "FK_MST_SUB_ACCOUNT_MST_ACCOUNT_ACCOUNT_NO", on_delete: :cascade
  add_foreign_key "TRN_CAPTURE_DATA", "MST_DEPARTMENT", column: "DEPARTMENT_NO", primary_key: "DEPARTMENT_NO"
  add_foreign_key "TRN_CAPTURE_DATA", "TRN_CAPTURE_HISTORY", column: "CAPTURE_HISTORY_NO", primary_key: "CAPTURE_HISTORY_NO"
  add_foreign_key "TRN_JOURNAL_ENTRY_HISTORY", "MST_CAPTURE_CATEGORY", column: "CAPTURE_CATEGORY_NO", primary_key: "CAPTURE_CATEGORY_NO"
  add_foreign_key "users", "users", column: "created_by_id", name: "fk_users_created_by"
  add_foreign_key "users", "users", column: "updated_by_id", name: "fk_users_updated_by"
end
