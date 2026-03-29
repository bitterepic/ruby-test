require "test_helper"
require "test_helpers/testing"

class UserFlowsTest < Testing::IntegrationTest
  test "create a subscription" do
    ## Create the placeholder for a subscription
    post "/subscriptions", params: { user_id, tansaction_id,product_id }, as: :json
    assert_response :created

    post "/webhooks/transactions", params: {
      "notification_uuid": "string",
      "type": "PURCHASE" "RENEW" "CANCEL",
      "transaction_id": "string",
      "product_id": "string",
      "amount": "3.9",
      "currency": "USD",
      "purchase_date": "2025-10-01T12:00:00Z",
      "expires_date": "2025-11-01T12:00:00Z"
    }, as: :json
    assert_response :created

    get subscription_url(:id)
    assert_response :success

  end
end
