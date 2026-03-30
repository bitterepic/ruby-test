# typed: true
# frozen_string_literal: true

# A transaction to update a subscription
class Transaction < ApplicationRecord
  extend T::Sig

  enum :status, { purchase: 0, renew: 1, cancel: 3 }
  belongs_to :subscription

  sig { returns(T::Boolean) }
  def expired
    Date.parse(expires_date) < Time.now
  end

sig { returns(T::Boolean) }
  def active
    !self.expired
  end
end
