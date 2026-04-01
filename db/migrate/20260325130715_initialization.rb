# frozen_string_literal: true

# Initialization of the database
class Initialization < ActiveRecord::Migration[8.1]
  def create_subscriptions_table
    create_table 'subscriptions', force: :cascade do |t|
      t.belongs_to :user, index: true, foreign_key: true, comment: "The user that owns this subscription"
      t.belongs_to :product, index: true, foreign_key: true, comment: "The product this subscription represents"
      t.datetime :created_at, null: false
    end
  end

  def create_transactions_table
    create_table 'transactions', force: :cascade do |t|
      t.string :external_id, null: false, index: { unique: true }, comment: "notification_uiid for APPLE"
      t.integer :source, null: false, comment: "apple or google or web"
      t.integer :type, null: false, comment: "purchase or renew or cancel"
      t.decimal :amount, null: false
      t.string :currency, null: false
      t.datetime :purchase_date, null: false, index: true
      t.datetime :expires_date, null: false, index: true
      t.datetime :created_at, null: false, index: true

      t.belongs_to :subscription, index: true, foreign_key: true
    end
  end

  def create_users_table
    create_table 'users', force: :cascade do |t|
      t.string :given_name, null: false
      t.string :family_name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.datetime :created_at, null: false
    t.string :roles, null: false, default: [].to_json
    end
  end

  def create_products_table
    create_table 'products', force: :cascade do |t|
      t.string :name, null: false
      t.datetime :created_at, null: false
    end
  end

  def change
    create_products_table
    create_users_table
    create_subscriptions_table
    create_transactions_table
  end
end
