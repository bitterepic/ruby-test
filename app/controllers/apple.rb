# typed: strict

class TransactionsController < ApplicationController
  extend T::Sig

  # POST /webhooks/apple/transaction
  sig { returns(String) }
  def create
    new_transaction = Transaction.new(transaction_params)

    if new_transaction.save
      render json: new_transaction, status: :created, location: "/webhooks/apple/transaction"
    else
      render json: new_transaction.errors, status: :unprocessable_content
    end
  end

  private
    sig { returns(ActionController::Parameters) }
    def transaction_params
      params.expect(transaction: [ :notification_uuid, :type, :amount, :status, :purchase_date, :expires_date ])
    end
end
