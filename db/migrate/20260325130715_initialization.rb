# frozen_string_literal: true

# Initialization of the database
class Initialization < ActiveRecord::Migration[8.1]
  def change
    create_table 'subscriptions', force: :cascade do
      t.string :user_id, null: false
      t.datetime :expires_date, null: false

      has_many :transactions
      belongs_to :user, foreign_key: true
      belongs_to :product, foreign_key: true
    end

    create_table 'transactions', force: :cascade do
      t.string :notification_uuid, null: false
      t.enum :status, [ :purchase, :renew, :cancel ]
      t.decimal :amount, null: false
      t.datetime :purchase_date, null: false
      t.datetime :expires_date, null: false

      belongs_to :subscription, foreign_key: true
    end

    create_table 'users', force: :cascade do
      t.string :given_name, null: false
      t.string :family_name, null: false
      t.string :email, null: false

      has_many :transactions
      has_many :subscriptions, through: :transactions
    end

    create_table 'product', force: :cascade do
      t.string :name, null: false
    end
  end
end
