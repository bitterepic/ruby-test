# typed: strict

class AppleTransactionsController < ApplicationController
  extend T::Sig

  class DuplicateNotificationError < StandardError; end
  class InvalidExpirationError < StandardError; end
  class PurchaseMustBeFirstTransaction < StandardError; end
  class AlreadyCancelledError < StandardError; end
  class SubscriptionNotFound < StandardError; end

  rescue_from DuplicateNotificationError, with: :handle_nonfatal_error
  rescue_from InvalidExpirationError, with: :handle_nonfatal_error
  rescue_from PurchaseMustBeFirstTransaction, with: :handle_nonfatal_error
  rescue_from AlreadyCancelledError, with: :handle_nonfatal_error
  rescue_from SubscriptionNotFound, with: :handle_nonfatal_error

  # POST /webhooks/apple/transaction
  sig { returns(String) }
  def create
    Rails.logger.info "START: #{self.class.name}"

    subscription = T.let(Subscription.find(transaction_params[:transaction_id]), T.nilable(Subscription))
    throw SubscriptionNotFound.new(transaction_params) if subscription.nil?

    previous_transaction = T.let(subscription.transactions.first, T.nilable(Transaction))
    transaction_params => { external_id: notification_uuid, **leftover_transaction_params }
    new_transaction = Transaction.new({ notification_uuid:, source: "apple", **leftover_transaction_params })

    already_exists = Transaction.exists?(notification_uuid: new_transaction.notification_uuid)
    throw DuplicateNotificationError.new(transaction_params) if already_exists

    invalid_expiration = previous_transaction && previous_transaction.expires_date >= new_transaction.expires_date
    throw InvalidExpirationError.new(transaction_params) if invalid_expiration

    Rails.logger.info "SUCCESS: #{self.class.name}"

    render nothing: true, status: :success, location: "/webhooks/apple/transaction"
  end

  private
    sig { returns(ActionController::Parameters) }
    def transaction_params
      params.expect(transaction: [ :notification_uuid, :type, :amount, :status, :purchase_date, :expires_date ])
    end

  sig { params(exception: StandardError).returns(String) }
    def handle_nonfatal_error(exception)
      backtrace = exception.backtrace
      backtraceString = backtrace.join("\n") if !backtrace.nil?
      Rails.logger.error "ERROR: #{self.class.name} #{exception.class.name}: #{exception}", backtraceString

      render nothing: true, status: :success, location: "/webhooks/apple/transaction"
    end
end
