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

ActiveRecord::Schema[8.0].define(version: 2025_11_05_155352) do
  create_table "accounting_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "company_id"
    t.string "code"
    t.string "name"
    t.string "sub_code"
    t.string "sub_name"
    t.integer "disp_level"
    t.boolean "hidden", default: false
    t.integer "debit_tax_type", limit: 2
    t.integer "credit_tax_type", limit: 2
    t.integer "tax_autocalc", limit: 1
    t.integer "tax_rate", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "code", "sub_code"], name: "index_accounting_items_on_company_id_and_code_and_sub_code", unique: true
    t.index ["company_id"], name: "index_accounting_items_on_company_id"
  end

  create_table "accounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "delete_flg", default: false, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.integer "updated_by_id"
    t.datetime "updated_at"
    t.integer "code"
  end

  create_table "bs_companies", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "business_connection_code"
    t.boolean "delete_flg", default: false, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.integer "updated_by_id"
    t.datetime "updated_at"
  end

  create_table "bs_departments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "company_id", null: false
    t.boolean "delete_flg", default: false, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.integer "updated_by_id"
    t.datetime "updated_at"
    t.index ["company_id"], name: "index_bs_departments_on_company_id"
  end

  create_table "business_connections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.boolean "hidden", default: false, null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_business_connections_on_created_by_id"
    t.index ["updated_by_id"], name: "index_business_connections_on_updated_by_id"
  end

  create_table "capture_categories", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "business_connection_code"
    t.string "business_connection_company_code"
    t.string "debit_department_code"
    t.integer "debit_account_code"
    t.integer "debit_account_sub_code"
    t.string "credit_department_code"
    t.integer "credit_account_code"
    t.integer "credit_account_sub_code"
    t.string "abstract"
    t.string "supplier_abstract"
    t.integer "journal_entry_pattern_group_no", null: false
    t.integer "payment_terms"
    t.boolean "delete_flg", default: false, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.integer "updated_by_id"
    t.datetime "updated_at"
    t.integer "tax_class_code", limit: 1
    t.integer "tax_rate_code", limit: 1
  end

  create_table "companies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.boolean "hidden", default: false, null: false
    t.string "business_connection_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "departments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "store_code", null: false
    t.string "store_name", null: false
    t.boolean "hidden", default: false, null: false
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
    t.index ["store_code"], name: "index_departments_on_store_code", unique: true
  end

  create_table "journal_entry_patterns", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "group_no", null: false
    t.string "name", null: false
    t.integer "row_no", null: false
    t.integer "date_pattern_no", null: false
    t.string "company_code"
    t.string "debit_department_code"
    t.integer "debit_account_code"
    t.integer "debit_account_sub_code"
    t.string "debit_business_connection_code"
    t.string "credit_department_code"
    t.integer "credit_account_code"
    t.integer "credit_account_sub_code"
    t.string "credit_business_connection_code"
    t.boolean "fixed_amount_flag", default: false, null: false
    t.integer "fixed_amount"
    t.boolean "filter_ratio_flag", default: false, null: false
    t.integer "filter_ratio"
    t.boolean "filter_amount_flag", default: false, null: false
    t.integer "filter_amount"
    t.integer "detail_division_no"
    t.boolean "include_tax_flag", default: false, null: false
    t.boolean "tax_calc_flag", default: false, null: false
    t.boolean "accure_flag", default: false, null: false
    t.boolean "delete_flg", default: false, null: false
    t.string "abstract"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at"
    t.integer "debit_tax_class_code", limit: 1
    t.integer "credit_tax_class_code", limit: 1
    t.integer "debit_tax_rate_code", limit: 1
    t.integer "credit_tax_rate_code", limit: 1
  end

  create_table "sub_accounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "sub_code", null: false
    t.string "name", null: false
    t.integer "code", null: false
    t.boolean "delete_flg", default: false, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.integer "updated_by_id"
    t.datetime "updated_at"
    t.index ["code", "sub_code"], name: "index_sub_accounts_on_code_and_sub_code", unique: true
  end

  create_table "suppliers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "delete_flg", default: false, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.integer "updated_by_id"
    t.datetime "updated_at"
  end

  create_table "tax_classes", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "delete_flg", default: false, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.integer "updated_by_id"
    t.datetime "updated_at"
  end

  create_table "tax_rates", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "rate", null: false
    t.boolean "delete_flg", default: false, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.integer "updated_by_id"
    t.datetime "updated_at"
  end

  create_table "trn_capture_histories", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "capture_category_id", null: false
    t.date "accrual_month"
    t.date "payment_month"
    t.boolean "lock_flg", default: false, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.index ["capture_category_id"], name: "fk_rails_6b3f99d39c"
  end

  create_table "trn_capture_records", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "capture_history_id", null: false
    t.integer "row_no", null: false
    t.string "company_code", null: false
    t.string "department_code", null: false
    t.string "business_connection_code"
    t.integer "account_code"
    t.integer "account_sub_code"
    t.integer "amount", null: false
    t.integer "second_amount", null: false
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.string "list_cd"
    t.integer "tax_class_code", limit: 1
    t.integer "tax_rate_code", limit: 1
    t.index ["capture_history_id"], name: "index_trn_capture_records_on_capture_history_id"
    t.index ["department_code"], name: "index_trn_capture_records_on_department_code"
  end

  create_table "trn_journal_entry_histories", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "capture_history_id", null: false
    t.integer "capture_category_id", null: false
    t.date "accrual_month"
    t.date "payment_month", null: false
    t.boolean "execute_flag", default: false, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.index ["capture_category_id"], name: "fk_rails_98e1ec1471"
  end

  create_table "trn_journal_entry_records", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "journal_entry_history_id", null: false
    t.integer "excel_row_no", null: false
    t.integer "row_no", null: false
    t.date "date", null: false
    t.string "company_code", null: false
    t.string "department_code"
    t.string "debit_department_code"
    t.integer "debit_account_code"
    t.integer "debit_account_sub_code"
    t.integer "debit_amount"
    t.string "debit_business_connection_code"
    t.string "credit_department_code"
    t.integer "credit_account_code"
    t.integer "credit_account_sub_code"
    t.integer "credit_amount"
    t.string "credit_business_connection_code"
    t.string "abstract"
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.integer "debit_tax_class_code", limit: 1
    t.integer "credit_tax_class_code", limit: 1
    t.integer "debit_tax_rate_code", limit: 1
    t.integer "credit_tax_rate_code", limit: 1
    t.index ["credit_department_code"], name: "index_trn_journal_entry_records_on_credit_department_code"
    t.index ["debit_department_code"], name: "index_trn_journal_entry_records_on_debit_department_code"
    t.index ["department_code"], name: "index_trn_journal_entry_records_on_department_code"
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

  add_foreign_key "accounting_items", "companies"
  add_foreign_key "bs_departments", "bs_companies", column: "company_id", name: "fk_departments_company", on_delete: :cascade
  add_foreign_key "business_connections", "users", column: "created_by_id"
  add_foreign_key "business_connections", "users", column: "updated_by_id"
  add_foreign_key "sub_accounts", "accounts", column: "code"
  add_foreign_key "sub_accounts", "accounts", column: "code"
  add_foreign_key "trn_capture_histories", "capture_categories"
  add_foreign_key "trn_capture_records", "trn_capture_histories", column: "capture_history_id"
  add_foreign_key "trn_journal_entry_histories", "capture_categories"
  add_foreign_key "users", "users", column: "created_by_id", name: "fk_users_created_by"
  add_foreign_key "users", "users", column: "updated_by_id", name: "fk_users_updated_by"
end
