# frozen_string_literal: true

# A user logged into the app
class User < ApplicationRecord
  has_secure_password

  has_many :subscriptions
  has_many :transactions, through: :subscriptions

  validates :email, uniqueness: true
end
