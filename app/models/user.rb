# typed: true
# frozen_string_literal: true

class StringArray
  extend T::Sig
  attr_reader :line, :city, :country

  sig { params(payload: String).returns(T::Array[String]) }
  def self.load(payload)
    data = JSON.parse(payload)
    if data.kindOf? Array
      data.filter { | d | d.kindOf? String }
    end

    []
  end

  sig { params(payload: T::Array[String]).returns(String) }
  def self.dump(payload)
    JSON.generate(payload)
  end
end

# A user logged into the app
class User < ApplicationRecord
  extend T::Sig

  has_secure_password

  has_many :subscriptions
  has_many :transactions, through: :subscriptions

  validates :email, uniqueness: true

  sig { params(target: String).returns(T::Boolean) }
  def has_role?(target)
    roles.includes? target
  end

  serialize :roles, coder: StringArray
end
