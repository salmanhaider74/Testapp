# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_29_160501) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.bigint "order_id"
    t.integer "balance_cents", default: 0, null: false
    t.string "balance_currency", default: "USD", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_accounts_on_order_id"
    t.index ["resource_type", "resource_id"], name: "index_accounts_on_resource_type_and_resource_id"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.string "street"
    t.string "suite"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.boolean "is_default", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resource_type", "resource_id"], name: "index_addresses_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "customer_id"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.string "role"
    t.string "encrypted_ssn"
    t.date "dob"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "primary", default: false, null: false
    t.decimal "ownership"
    t.datetime "deleted_at"
    t.string "inquiry_id"
    t.datetime "verified_at"
    t.boolean "reviewed", default: false, null: false
    t.index ["customer_id", "email"], name: "index_contacts_on_customer_id_and_email", unique: true
    t.index ["customer_id", "primary"], name: "index_contacts_on_customer_id_and_primary", unique: true, where: "(\"primary\" IS TRUE)"
    t.index ["customer_id"], name: "index_contacts_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "vendor_id"
    t.string "name"
    t.string "duns_number"
    t.string "encrypted_ein"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "entity_type"
    t.date "date_started"
    t.string "number"
    t.integer "bill_cycle_day"
    t.datetime "verified_at"
    t.string "middesk_id"
    t.string "bin"
    t.boolean "reviewed", default: false, null: false
    t.index ["vendor_id"], name: "index_customers_on_vendor_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "order_id"
    t.bigint "personal_guarantee_id"
    t.string "type"
    t.jsonb "json_data", default: {}, null: false
    t.index ["customer_id"], name: "index_documents_on_customer_id"
    t.index ["order_id"], name: "index_documents_on_order_id"
    t.index ["personal_guarantee_id"], name: "index_documents_on_personal_guarantee_id"
  end

  create_table "dwolla_accounts", force: :cascade do |t|
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.string "is_master"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "verified", default: false, null: false
    t.string "funding_source"
    t.index ["resource_type", "resource_id"], name: "index_dwolla_accounts_on_resource_type_and_resource_id"
  end

  create_table "invoice_items", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "payment_schedule_item_id", null: false
    t.bigint "transaction_id"
    t.bigint "order_item_id"
    t.string "name"
    t.string "description"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "number"
    t.integer "amount_charged_cents", default: 0, null: false
    t.string "amount_charged_currency", default: "USD", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
    t.index ["order_item_id"], name: "index_invoice_items_on_order_item_id"
    t.index ["payment_schedule_item_id"], name: "index_invoice_items_on_payment_schedule_item_id"
    t.index ["transaction_id"], name: "index_invoice_items_on_transaction_id"
  end

  create_table "invoice_payments", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "payment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["invoice_id"], name: "index_invoice_payments_on_invoice_id"
    t.index ["payment_id"], name: "index_invoice_payments_on_payment_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "customer_id"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.string "status"
    t.date "posted_date"
    t.date "due_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "number"
    t.date "invoice_date"
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "name", null: false
    t.string "description", null: false
    t.integer "quantity", null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.string "unit_price_currency", default: "USD", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "number"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "status"
    t.string "billing_frequency"
    t.date "start_date"
    t.date "end_date"
    t.datetime "approved_at"
    t.datetime "declined_at"
    t.bigint "customer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "number"
    t.jsonb "workflow_steps", default: {}
    t.string "undewriting_engine_version", default: "V1"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.decimal "term"
    t.decimal "interest_rate", precision: 5, scale: 4
    t.decimal "interest_rate_subsidy", precision: 5, scale: 4
    t.string "signature_request_id"
    t.boolean "has_form", default: false, null: false
    t.bigint "product_id"
    t.boolean "application_sent", default: false, null: false
    t.string "loan_decision"
    t.string "vartana_rating"
    t.decimal "vartana_score", precision: 4, scale: 2
    t.boolean "manual_review", default: false, null: false
    t.boolean "fullcheck_consent", default: false, null: false
    t.jsonb "financial_details", default: {}, null: false
    t.bigint "user_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.boolean "is_default", default: false
    t.string "payment_mode"
    t.string "account_name"
    t.string "account_type"
    t.string "routing_number"
    t.string "encrypted_account_number"
    t.string "contact_name"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "bank"
    t.string "funding_source"
    t.boolean "verified", default: false, null: false
    t.index ["resource_type", "resource_id"], name: "index_payment_methods_on_resource_type_and_resource_id"
  end

  create_table "payment_schedule_items", force: :cascade do |t|
    t.bigint "payment_schedule_id"
    t.integer "principal_cents", default: 0, null: false
    t.string "principal_currency", default: "USD", null: false
    t.integer "interest_cents", default: 0, null: false
    t.string "interest_currency", default: "USD", null: false
    t.date "due_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "fees_cents", default: 0, null: false
    t.string "fees_currency", default: "USD", null: false
    t.integer "start_balance_cents", default: 0, null: false
    t.string "start_balance_currency", default: "USD", null: false
    t.index ["payment_schedule_id"], name: "index_payment_schedule_items_on_payment_schedule_id"
  end

  create_table "payment_schedules", force: :cascade do |t|
    t.bigint "account_id"
    t.integer "version", default: 1
    t.string "status"
    t.decimal "term"
    t.date "start_date"
    t.date "end_date"
    t.string "billing_frequency"
    t.decimal "interest_rate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_payment_schedules_on_account_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.string "external_id"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "error_message"
    t.bigint "payment_method_id", null: false
    t.string "number"
    t.index ["payment_method_id"], name: "index_payments_on_payment_method_id"
    t.index ["resource_type", "resource_id"], name: "index_payments_on_resource_type_and_resource_id"
  end

  create_table "personal_guarantees", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "contact_id", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contact_id"], name: "index_personal_guarantees_on_contact_id"
    t.index ["order_id", "contact_id"], name: "index_personal_guarantees_on_order_id_and_contact_id", unique: true
    t.index ["order_id"], name: "index_personal_guarantees_on_order_id"
  end

  create_table "plaid_tokens", force: :cascade do |t|
    t.string "access_token"
    t.string "item_id"
    t.string "request_id"
    t.string "account_id"
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resource_type", "resource_id"], name: "index_plaid_tokens_on_resource_type_and_resource_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "vendor_id", null: false
    t.string "name"
    t.boolean "is_active", default: false
    t.string "number"
    t.decimal "min_interest_rate_subsidy", precision: 5, scale: 4
    t.decimal "max_interest_rate_subsidy", precision: 5, scale: 4
    t.integer "min_initial_loan_amount_cents", default: 0, null: false
    t.string "min_initial_loan_amount_currency", default: "USD", null: false
    t.integer "min_subsequent_loan_amount_cents", default: 0, null: false
    t.string "min_subsequent_loan_amount_currency", default: "USD", null: false
    t.integer "max_loan_amount_cents", default: 0, null: false
    t.string "max_loan_amount_currency", default: "USD", null: false
    t.jsonb "pricing_schema", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["number"], name: "index_products_on_number", unique: true
    t.index ["vendor_id"], name: "index_products_on_vendor_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "last_active_at"
    t.inet "sign_in_ip"
    t.inet "current_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "order_id"
    t.index ["order_id"], name: "index_sessions_on_order_id"
    t.index ["resource_type", "resource_id"], name: "index_sessions_on_resource_type_and_resource_id"
    t.index ["token"], name: "index_sessions_on_token", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "order_id"
    t.string "type"
    t.string "status"
    t.integer "interest_cents", default: 0, null: false
    t.string "interest_currency", default: "USD", null: false
    t.integer "fees_cents", default: 0, null: false
    t.string "fees_currency", default: "USD", null: false
    t.integer "principal_cents", default: 0, null: false
    t.string "principal_currency", default: "USD", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "payment_id"
    t.string "number"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["order_id"], name: "index_transactions_on_order_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.bigint "vendor_id"
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["vendor_id"], name: "index_users_on_vendor_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.string "duns_number"
    t.string "ein"
    t.string "domain"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "number"
    t.boolean "test_mode", default: false, null: false
    t.jsonb "email_preferences", default: {}, null: false
    t.string "contact_email"
    t.index ["domain"], name: "index_vendors_on_domain", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "accounts", "orders"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "contacts", "customers"
  add_foreign_key "customers", "vendors"
  add_foreign_key "documents", "customers"
  add_foreign_key "documents", "orders"
  add_foreign_key "documents", "personal_guarantees"
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoice_items", "order_items"
  add_foreign_key "invoice_items", "payment_schedule_items"
  add_foreign_key "invoice_items", "transactions"
  add_foreign_key "invoice_payments", "invoices"
  add_foreign_key "invoice_payments", "payments"
  add_foreign_key "invoices", "customers"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "payment_schedule_items", "payment_schedules"
  add_foreign_key "payments", "payment_methods"
  add_foreign_key "personal_guarantees", "contacts"
  add_foreign_key "personal_guarantees", "orders"
  add_foreign_key "products", "vendors"
  add_foreign_key "sessions", "orders"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "orders"
  add_foreign_key "users", "vendors"
end
