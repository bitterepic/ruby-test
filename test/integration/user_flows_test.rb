require "test_helper"
require "test_helpers/testing"

class UserFlowsTest < Testing::IntegrationTest
  test "create a subscription" do
    TODO LOGIN

    ## Create the placeholder for a subscription
    post "/subscriptions", params: {
      user_id: user_id,
      transaction_id: transaction_id,
      product_id: product_id
    }, as: :json
    assert_response :created

    ## Webhook call enables subscription
    post "/webhooks/apple/transactions", params: {
      "notification_uuid": "1",
      "type": "PURCHASE",
      "transaction_id": "string",
      "product_id": "string",
      "amount": "3.9",
      "currency": "USD",
      "purchase_date": "2025-10-01T12:00:00Z",
      "expires_date": "2025-11-01T12:00:00Z"
    }, as: :json
    assert_response :created

    post "/webhooks/apple/transactions", params: {
      "notification_uuid": "2",
      "type": "RENEW",
      "transaction_id": "string",
      "product_id": "string",
      "amount": "3.9",
      "currency": "USD",
      "purchase_date": "2025-10-01T12:00:00Z",
      "expires_date": "2025-11-01T12:00:00Z"
    }, as: :json
    assert_response :created

    post "/webhooks/transactions", params: {
      "notification_uuid": "3",
      "type": "CANCEL",
      "transaction_id": "string",
      "product_id": "string",
      "expires_date": "2025-11-01T12:00:00Z"
    }, as: :json
    assert_response :created

    get subscription_url(:id)
    assert_response :success
  end
end
