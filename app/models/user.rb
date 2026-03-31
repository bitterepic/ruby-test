# typed: true
# frozen_string_literal: true

# A user logged into the app
class User < ApplicationRecord
  extend T::Sig

  has_secure_password

  has_many :subscriptions
  has_many :transactions, through: :subscriptions

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  sig { params(target: String).returns(T::Boolean) }
  def has_role?(target)
    roles.includes? target
  end

  serialize :roles, coder: JSON
end
