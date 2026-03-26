# frozen_string_literal: true

# Initialization of the database
class Initialization < ActiveRecord::Migration[8.1]
  def create_subscriptions_table
    create_table 'subscriptions', force: :cascade do |t|
      # Sort first
      #t.has_many :transactions, { order: 'purchase_date DESC' }
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :product, index: true, foreign_key: true
    end
  end

  def create_transactions_table
    create_table 'transactions', force: :cascade do |t|
      t.string :notification_uuid, null: false
      #t.enum :status, [:purchase, :renew, :cancel]
      t.decimal :amount, null: false
      t.datetime :purchase_date, null: false, index: true
      t.datetime :expires_date, null: false, index: true

      t.belongs_to :subscription, index: true, foreign_key: true
    end
  end

  def create_users_table
    create_table 'users', force: :cascade do |t|
      t.string :given_name, null: false
      t.string :family_name, null: false
      t.string :email, null: false, index: true

      #t.has_many :subscriptions
      #t.has_many :transactions, through: :subscriptions
    end
  end

  def create_products_table
    create_table 'product', force: :cascade do |t|
      t.string :name, null: false
    end
  end

  def change
    create_products_table
    create_users_table
    create_subscriptions_table
    create_transactions_table
  end
end
