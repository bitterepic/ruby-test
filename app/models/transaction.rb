# typed: true
# frozen_string_literal: true

# A transaction to update a subscription
class Transaction < ApplicationRecord
  extend T::Sig

  @@grace_period = 60.minutes

  enum :action, {
    purchase: 0,
    renew: 1,
    cancel: 3
  }

  enum :source, {
    apple: 0
    # FUTURE
    # google: 1,
    # web: 2
  }

  belongs_to :subscription

  sig { params(should_include_grace_period: T::Boolean).returns(T::Boolean) }
  def expired(should_include_grace_period = true)
    grace_period = should_include_grace_period ? @@grace_period : 0.minutes
    expires_date_with_grace_period = Date.parse(expires_date) + grace_period

    expires_date_with_grace_period < Time.now
  end

  sig { params(should_include_grace_period: T::Boolean).returns(T::Boolean) }
  def active(should_include_grace_period = true)
    !self.expired should_include_grace_period
  end
end
