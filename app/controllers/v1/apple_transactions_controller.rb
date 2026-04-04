# typed: strict

class V1::AppleTransactionsController < ApplicationController
  extend T::Sig

  # Nonfatal errors where the request should still return
  # a 200, even though internal it is a noop.
  class DuplicateNotificationError < StandardError; end
  class CancelationMustMatchPreviousError < StandardError; end
  class PurchaseMustBeFirstTransaction < StandardError; end
  class AlreadyCancelledError < StandardError; end
  class SubscriptionNotFound < StandardError; end

  rescue_from DuplicateNotificationError, with: :handle_nonfatal_error
  rescue_from CancelationMustMatchPreviousError, with: :handle_nonfatal_error
  rescue_from PurchaseMustBeFirstTransaction, with: :handle_nonfatal_error
  rescue_from AlreadyCancelledError, with: :handle_nonfatal_error
  rescue_from SubscriptionNotFound, with: :handle_nonfatal_error

  # POST /webhooks/apple/transaction
  sig { returns(String) }
  def create
    Rails.logger.info "START: #{self.class.name}"
    raise ForbiddenError.new if authenticated_user.has_role? "apple"

    subscription = T.let(Subscription.find(transaction_params[:transaction_id]), T.nilable(Subscription))
    raise SubscriptionNotFound.new(transaction_params) if subscription.nil?

    previous_transaction = subscription.transactions.order(created_at: :asc).select(
      :id,
      :action,
      :created_at,
      :currency,
      :expires_date,
      :external_id,
      :purchase_date,
      :source
    ).last
    transaction_params2 = {
      "external_id" => transaction_params[:notification_uuid],
      "action" => transaction_params[:type],
      "subscription_id" => transaction_params[:transaction_id],
      "amount" => transaction_params[:amount],
      "currency" => transaction_params[:currency],
      "purchase_date" => transaction_params[:purchase_date],
      "expires_date" => transaction_params[:expires_date],
      "source" => "apple"
    }

    already_exists = Transaction.exists?(external_id: transaction_params2["external_id"])
    raise DuplicateNotificationError.new(transaction_params2) if already_exists

    already_cancelled = (
      transaction_params2["action"] == "cancel" && previous_transaction&.action == "cancel"
    )
    raise AlreadyCancelledError.new(transaction_params2) if already_cancelled

    cancelled_matches_previous = (
    previous_transaction && transaction_params["action"] == "cancel" && (previous_transaction.expires_date != DateTime.parse(transaction_params2["expires_date"]) || previous_transaction.purchase_date != DateTime.parse(transaction_params2["purchase_date"]))
    )
    raise CancelationMustMatchPreviousError.new(transaction_params2) if cancelled_matches_previous 

    purchase_before_expiration = (
    previous_transaction && transaction_params["action"] != "cancel" && (previous_transaction.expires_date > DateTime.parse(transaction_params2["purchase_date"]))
    )
    raise CancelationMustMatchPreviousError.new(transaction_params2) if purchase_before_expiration

    new_transaction = Transaction.new(transaction_params2)

    if new_transaction.save
      Rails.logger.info "SUCCESS: #{self.class.name}"
      render json: { transaction: new_transaction }, status: :created, location: v1_apple_transactions_path
    else
      Rails.logger.info "ERROR: #{self.class.name} unprocessable_content #{new_transaction.errors}"
      new_transaction.errors.pretty_print_inspect
      render json: new_transaction.errors, status: :unprocessable_content
    end
  end

  private
    sig { returns(ActionController::Parameters) }
    def transaction_params
      params.expect(transaction: [
        :notification_uuid,
        :type,
        :transaction_id,
        :product_id,
        :amount,
        :currency,
        :purchase_date,
        :expires_date
    ])
    end

    # Webhooks and call with the same message multiple times.  Unless a fatal error happens,
    # this API should return a 200.
    sig { params(exception: StandardError).returns(String) }
    def handle_nonfatal_error(exception)
      backtrace = exception.backtrace
      backtraceString = backtrace.join("\n") if !backtrace.nil?

      Rails.logger.error "ERROR: #{self.class.name} #{exception.class.name}: #{exception}\n #{backtraceString}"

      render json: { message: "Errored" }, status: :created, location: "/webhooks/apple/transaction"
    end
end
