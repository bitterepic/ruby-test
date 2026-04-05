require 'swagger_helper'

RSpec.describe 'api/v1/apple_transactions', type: :request do
  path '/v1/webhooks/apple/transactions' do
    post 'Create a transaction for a subscription' do
      tags 'Webhooks'
      consumes 'application/json'
      security [ Bearer: {} ]
      description %Q(
An endpoint used for adding transactions to a subscription. Transactions record actions by the user for a subscription. The last 
transaction is the active one for a subscription, while the rest can be used for record keeping.

There are three different action types: `purchase`, `cancel` and `renew`.

NOTE: The `transaction_id` of this request maps to the related subscription `id` and `notification_uuid` is recorded as the `external_id`.

- A purchase transaction is the first transaction for a subscription.  It is not active until created.
- A renew must have a `purchase_date` that starts at the expiration of the previous transaction.  
- A cancel transaction must share the same `purchase_date` and `expiration_date` as the previous transaction.
        ).chomp
      request_body_example(value: {
        "transaction": {
          "notification_uuid": "4d249252-118d-42c6-99b8-75ded060ceea",
          "type": "purchase",
          "amount": "3.9",
          "currency": "USD",
          "transaction_id": 1,
          "product_id": 1,
          "purchase_date": "1990-01-01T00:01:00.000Z",
          "expires_date": "1990-02-01T12:00:00.000Z"
        }
      }, name: "Purchase a subscription", summary: "Purchase a subscription.")
      request_body_example(value: {
        "transaction": {
          "notification_uuid": "f949aaaa-f912-463d-8721-56da71e86a4d",
          "type": "cancel",
          "transaction_id": 1,
          "product_id": 1,
          "purchase_date": "1990-01-01T00:01:00.000Z",
          "expires_date": "1990-02-01T12:00:00.000Z"
        }
      }, name: "Cancel a subscription", summary: "Cancel a subscription.")
      request_body_example(value: {
        "transaction": {
          "notification_uuid": "f949aaaa-f912-463d-8721-56da71e86a4d",
          "type": "renew",
          "amount": "3.9",
          "currency": "USD",
          "transaction_id": 1,
          "product_id": 1,
          "purchase_date": "1990-01-01T00:01:00.000Z",
          "expires_date": "1990-02-01T12:00:00.000Z"
        }
      }, name: "Renew a subscription", summary: "Renew a subscription.")
      parameter name: 'body', in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :number }
        },
        required: [ 'product_id' ]
      }

      response '201', 'Transaction created' do
        let(:"authorization") { "Bearer #{token_for(user)}" }
        example 'application/json', :success, {
          "transaction": {
            "id": 1,
            "external_id": "4d249252-118d-42c6-99b8-75ded060ceea",
            "source": "apple",
            "action": "purchase",
            "amount": "3.9",
            "currency": "USD",
            "purchase_date": "1990-01-01T00:01:00.000Z",
            "expires_date": "1990-02-01T12:00:00.000Z",
            "created_at": "2026-04-04T13:21:00.691Z",
            "subscription_id": 1
          }
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        example 'application/json', :success, {
          "message": "Please log in"
        }
        run_test!
      end

      response '422', 'Creation failed' do
        example 'application/json', :success, {
          "errors": {
            "product": [
              "must exist"
            ]
          }
        }
        run_test!
      end
    end
  end
end
