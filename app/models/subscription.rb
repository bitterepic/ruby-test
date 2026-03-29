# frozen_string_literal: true

# A subscription for a product for a user
class Subscription < ApplicationRecord
  has_many :transactions, -> { order "purchase_date DESC" }
  belongs_to :user
  belongs_to :product
end
