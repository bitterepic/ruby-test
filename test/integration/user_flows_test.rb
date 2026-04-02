# typed: true

require "test_helper"
require "test_helpers/testing"

class UserFlowsTest < Testing::IntegrationTest
  extend T::Sig

  setup do
    @tranaction_increment = 0
    # Set our testing timestamp
    Timecop.freeze(DateTime.new(1990).utc)

    register
    login

    @token = T.let(response.parsed_body["token"], String)
    @user_id = T.let(response.parsed_body["id"], Integer)
    @headers = { Authorization: "Bearer #{@token}" }

    assert_response :success
  end

  teardown do
    Timecop.return
  end

  sig { params(product_id: Integer).returns(Integer) }
  def create_subscription(product_id)
    post subscriptions_path, params: {
      subscription: { product_id: }
    }, headers: @headers, as: :json
    assert_response :created
    response.parsed_body["id"]
  end

  sig { params(
    product_id: Integer,
    subscription_id: Integer,
    purchase_date: String,
    expires_date: String
  ).returns(Integer) }
  def purchase(product_id, subscription_id, purchase_date, expires_date)
    @tranaction_increment += 1
    Timecop.freeze(DateTime.new(1990).utc + @tranaction_increment.minute) do
      post apple_transactions_path, params: {
        transaction: {
          "notification_uuid": @tranaction_increment,
          "type": "purchase",
          "transaction_id": subscription_id,
          "product_id": product_id,
          "amount": "3.9",
          "currency": "USD",
          purchase_date:,
          expires_date:
        }
      }, headers: @headers, as: :json

      assert_response :created

      response.parsed_body[:transaction][:id]
    end
  end

  sig { params(
    product_id: Integer,
    subscription_id: Integer,
    purchase_date: String,
    expires_date: String
  ).returns(Integer) }
  def renew(product_id, subscription_id, purchase_date, expires_date)
    @tranaction_increment += 1
    Timecop.freeze(DateTime.new(1990).utc + @tranaction_increment.minute) do
      post apple_transactions_path, params: {
        transaction: {
          "notification_uuid": @tranaction_increment,
          "type": "renew",
          "transaction_id": subscription_id,
          "product_id": product_id,
          "amount": "3.9",
          "currency": "USD",
          purchase_date:,
          expires_date:
        }
      }, headers: @headers, as: :json

      assert_response :created

      response.parsed_body[:transaction][:id]
    end
  end

  sig { params(
    product_id: Integer,
    subscription_id: Integer,
    purchase_date: String,
    expires_date: String
  ).returns(Integer) }
  def cancel(product_id, subscription_id, purchase_date, expires_date)
    @tranaction_increment += 1
    Timecop.freeze(DateTime.new(1990).utc + @tranaction_increment.minute) do
      post apple_transactions_path, params: {
        transaction: {
          "notification_uuid": @tranaction_increment,
          "type": "cancel",
          "transaction_id": subscription_id,
          "product_id": product_id,
          expires_date:
        }
      }, headers: @headers, as: :json

      assert_response :created

      response.parsed_body[:transaction][:id]
    end
  end

  test "create a subscription" do
    product_id = products(:monthly).id
    subscription_id = create_subscription product_id

    get subscription_path(subscription_id), headers: @headers, as: :json
    assert_response :success

    assert_equal({
      "id" => subscription_id,
      "created_at" => "1990-01-01T00:00:00.000Z",
      "product_id" => product_id,
      "user_id" => @user_id,
      "last_transaction" => nil 
    }, response.parsed_body)
  end

  test "create a subscription with purchase" do
    product_id = products(:monthly).id
    subscription_id = create_subscription product_id
    purchase_transaction_id = purchase(product_id, subscription_id, "2025-01-01T12:00:00.000Z", "2025-02-01T12:00:00.000Z")

    get subscription_path(subscription_id), headers: @headers, as: :json
    assert_response :success

    assert_equal({
      "id" => subscription_id,
      "created_at" => "1990-01-01T00:00:00.000Z",
      "product_id" => product_id,
      "user_id" => @user_id,
      "last_transaction" => {
        "id" => purchase_transaction_id,
        "action" => "purchase",
        "created_at" => "1990-01-01T00:01:00.000Z",
        "currency" => "USD",
        "expires_date" => "2025-02-01T12:00:00.000Z",
        "external_id" => "1",
        "purchase_date" => "2025-01-01T12:00:00.000Z",
        "source" => "apple"
      }
    }, response.parsed_body)
  end

  test "create a subscription with a renew" do
    product_id = products(:monthly).id
    subscription_id = create_subscription product_id
    purchase_transaction_id = purchase(
      product_id, 
      subscription_id, 
      "2025-01-01T12:00:00.000Z", 
      "2025-02-01T12:00:00.000Z"
    )
    renew_transaction_id = renew(
      product_id, 
      subscription_id, 
      "2025-02-01T12:00:00.000Z", 
      "2025-03-01T12:00:00.000Z"
    )

    get subscription_path(subscription_id), headers: @headers, as: :json
    assert_response :success

    assert_equal({
      "id" => subscription_id,
      "created_at" => "1990-01-01T00:00:00.000Z",
      "product_id" => product_id,
      "user_id" => @user_id,
      "last_transaction" => {
        "id" => renew_transaction_id,
        "action" => "renew",
        "created_at" => "1990-01-01T00:02:00.000Z",
        "currency" => "USD",
        "expires_date" => "2025-03-01T12:00:00.000Z",
        "external_id" => "2",
        "purchase_date" => "2025-02-01T12:00:00.000Z",
        "source" => "apple"
      }
    }, response.parsed_body)
  end

  test "create a subscription with a cancel" do
    product_id = products(:monthly).id
    subscription_id = create_subscription product_id
    purchase_transaction_id = purchase(
      product_id, 
      subscription_id, 
      "2025-01-01T12:00:00.000Z", 
      "2025-02-01T12:00:00.000Z"
    )
    cancel_transaction_id = cancel(
      product_id, 
      subscription_id, 
      "2025-01-01T12:00:00.000Z", 
      "2025-02-01T12:00:00.000Z"
    )

    get subscription_path(subscription_id), headers: @headers, as: :json
    assert_response :success

    assert_equal({
      "id" => subscription_id,
      "created_at" => "1990-01-01T00:00:00.000Z",
      "product_id" => product_id,
      "user_id" => @user_id,
      "last_transaction" => {
        "action" => "cancel",
        "created_at" => "1990-01-01T00:02:00.000Z",
        "expires_date" => "2025-02-01T12:00:00.000Z",
        "currency" => nil,
        "external_id" => "2",
        "id" => cancel_transaction_id,
        "purchase_date" => nil,
        "source" => "apple"
      }
    }, response.parsed_body)
  end
end
