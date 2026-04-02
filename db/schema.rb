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

ActiveRecord::Schema[8.1].define(version: 2026_03_25_130715) do
  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "product_id"
    t.integer "user_id"
    t.index ["product_id"], name: "index_subscriptions_on_product_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "action", null: false
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.string "currency"
    t.datetime "expires_date", null: false
    t.string "external_id", null: false
    t.datetime "purchase_date"
    t.integer "source", null: false
    t.integer "subscription_id"
    t.index ["created_at"], name: "index_transactions_on_created_at"
    t.index ["expires_date"], name: "index_transactions_on_expires_date"
    t.index ["external_id"], name: "index_transactions_on_external_id", unique: true
    t.index ["purchase_date"], name: "index_transactions_on_purchase_date"
    t.index ["subscription_id"], name: "index_transactions_on_subscription_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "family_name", null: false
    t.string "given_name", null: false
    t.string "password_digest", null: false
    t.string "roles", default: "[]", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "subscriptions", "products"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "transactions", "subscriptions"
end
