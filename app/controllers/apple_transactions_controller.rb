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
    transaction_params => { notification_uuid: external_id, **leftover_transaction_params }

    already_exists = Transaction.exists?(external_id: transaction_params[:external_id])
    throw DuplicateNotificationError.new(transaction_params) if already_exists

    invalid_expiration = (previous_transaction && transaction_params['type'] != "CANCEL") ? previous_transaction.expires_date >= transaction_params[:expires_date] : false
    throw InvalidExpirationError.new(transaction_params) if invalid_expiration

    new_transaction = Transaction.new({ external_id:, source: "apple", **leftover_transaction_params })

    if new_transaction.save
      Rails.logger.info "SUCCESS: #{self.class.name}"
      render json: new_transaction, status: :created, location: "/webhooks/apple/transaction"
    else
      Rails.logger.info "ERROR: #{self.class.name} unprocessable_content #{new_transaction.errors}"
      render json: new_transaction.errors, status: :unprocessable_content
    end
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
