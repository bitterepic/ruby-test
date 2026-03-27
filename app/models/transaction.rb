# frozen_string_literal: true

# A transaction to update a subscription
class Transaction < ApplicationRecord
  enum :status, { purchase: 0, renew: 1, cancel: 3 }
  belongs_to :subscription
end
