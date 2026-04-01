# typed: true

require "test_helper"
require "test_helpers/testing"

class UserFlowsTest < Testing::IntegrationTest
  extend T::Sig

  setup do
    # Set our testing timestamp
    Timecop.freeze(DateTime.new(1990).utc)

    # Create the user
    post "/register", params: {
      email: "test@example.com",
      family_name: "test family name",
      given_name: "test given name",
      password: "012345678"
    }, as: :json

    assert_response :success

    post "/login", params: {
      email: "test@example.com",
      password: "012345678"
    }, as: :json

    @token = T.let(response.parsed_body["token"], String)
    @user_id = T.let(response.parsed_body["id"], Integer)
    @headers = { Authorization: "Bearer #{@token}" }

    assert_response :success
  end

  teardown do
    Timecop.return
  end

  test "create a subscription" do
    ## Create the placeholder for a subscription
    product_id = products(:monthly).id
    post subscriptions_path, params: {
      subscription: { product_id: }
    }, headers: @headers, as: :json
    assert_response :created
    subscription_id = response.parsed_body["id"]

    ## Webhook call enables subscription
    post apple_transactions_path, params: {
      transaction: {
        "notification_uuid": "1",
        "type": "purchase",
        "transaction_id": subscription_id,
        "product_id": product_id,
        "amount": "3.9",
        "currency": "USD",
        "purchase_date": "2025-10-01T12:00:00Z",
        "expires_date": "2025-11-01T12:00:00Z"
      }
    }, headers: @headers, as: :json
    assert_response :created

    get subscription_path(subscription_id), headers: @headers, as: :json
    assert_response :success

    assert_equal({
      "id" => 904941505,
      "created_at" => "1990-01-01T00:00:00.000Z",
      "product_id" => 715507355,
      "user_id" => 1072791106,
      "last_transaction" => {
        "id" => 555209021,
        "action" => "purchase",
        "created_at" => "1990-01-01T00:00:00.000Z",
        "currency" => "USD",
        "expires_date" => "2025-11-01T12:00:00.000Z",
        "external_id" => "1",
        "purchase_date" => "2025-10-01T12:00:00.000Z",
        "source" => "apple"
      }
    }, response.parsed_body)

    ### Webhook call to renew
    # post "/webhooks/apple/transactions", params: {
    # transaction: {
    #  "notification_uuid": "2",
    #  "type": "RENEW",
    #  "transaction_id": "string",
    #  "product_id": "string",
    #  "amount": "3.9",
    #  "currency": "USD",
    #  "purchase_date": "2025-10-01T12:00:00Z",
    #  "expires_date": "2025-11-01T12:00:00Z"
    # }, headers: { Authorization: "Bearer #{@token}" }, as: :json
    # assert_response :created

    ### Webhook call to cancel subscription
    # post "/webhooks/transactions", params: {
    # transaction: {
    #  "notification_uuid": "3",
    #  "type": "CANCEL",
    #  "transaction_id": "string",
    #  "product_id": "string",
    #  "expires_date": "2025-11-01T12:00:00Z"
    # }, headers: { Authorization: "Bearer #{@token}" }, as: :json
    # assert_response :created

    # get subscription_url(:id)
    # assert_response :success
  end
end
