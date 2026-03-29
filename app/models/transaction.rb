# typed: true
# frozen_string_literal: true

# A transaction to update a subscription
class Transaction < ApplicationRecord
  extends T::Sig

  enum :status, { purchase: 0, renew: 1, cancel: 3 }
  belongs_to :subscription

  sig { returns(T::BOolean) }
  def expired
    expires_date <=> Time.now.isoiso8601 < 0
  end

sig { returns(T::Boolean) }
  def active
    !self.expired
  end
end
