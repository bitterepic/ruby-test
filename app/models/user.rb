# frozen_string_literal: true

# A user logged into the app
class User < ApplicationRecord
  has_many :subscriptions
  has_many :transactions, through: :subscriptions
end
