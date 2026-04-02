# typed: strict

require "test_helper"
require "test_helpers/testing"

class SubscriptionsControllerTest < Testing::IntegrationTest
  extend T::Sig

  setup do
    # Set our testing timestamp
    Timecop.freeze(DateTime.new(1990).utc)

    register
    login
  end

  teardown do
    Timecop.return
  end

  test "should get index" do
    subscription = Subscription.new(product: products(:monthly), user_id: @user_id)
    subscription.save

    get v1_subscriptions_path, headers: { Authorization: "Bearer #{@token}" }, as: :json
    assert_response :success
    assert_equal [ {
      "id" => subscription.id,
      "created_at" =>  "1990-01-01T00:00:00.000Z",
      "product_id" => products(:monthly).id,
      "user_id" =>  @user_id
    } ], response.parsed_body
  end

  test "should not return index when not authorized" do
    subscription = Subscription.new(product: products(:monthly), user_id: @user_id)
    subscription.save

    get v1_subscriptions_path, as: :json
    assert_response :unauthorized
  end

  test "should not create subscription when unauthorized" do
    product = products(:monthly)

    post v1_subscriptions_path, params: {
      subscription: { product_id: product.id }
    }, as: :json

    assert_response :unauthorized

    expected_subscriptions = [ *subscriptions ]
    actual_subscriptions = Subscription.all

    assert_equal expected_subscriptions.to_json, actual_subscriptions.to_json
  end


  test "should create subscription" do
    product = products(:monthly)

    post v1_subscriptions_path, params: {
      subscription: { product_id: product.id }
    }, headers: { Authorization: "Bearer #{@token}" }, as: :json

    assert_response :created

    expected_subscriptions = [ *subscriptions, {
      id: response.parsed_body[:id],
      created_at: "1990-01-01T00:00:00.000Z",
      product_id: product.id,
      user_id: @user_id
    } ]
    actual_subscriptions = Subscription.all

    assert_equal expected_subscriptions.to_json, actual_subscriptions.to_json
  end

  test "can't show subscription by other user" do
    subscription = subscriptions(:basic_subscription)
    get v1_subscription_url(subscription.id), headers: { Authorization: "Bearer #{@token}" }, as: :json
    assert_response :forbidden
  end

  test "should show own subscription" do
    subscription = Subscription.new(user_id: @user_id, product: products(:monthly))
    subscription.save

    get v1_subscription_url(subscription.id), headers: { Authorization: "Bearer #{@token}" }, as: :json
    assert_response :success

    assert_equal({
      "id" => subscription.id,
      "created_at" => "1990-01-01T00:00:00.000Z",
      "product_id" => products(:monthly).id,
      "user_id" => @user_id,
      "last_transaction" => nil
    }, response.parsed_body)
  end

  test "can't show when doesn't exist" do
    subscription = subscriptions(:basic_subscription)
    get v1_subscription_url(10000), headers: { Authorization: "Bearer #{@token}" }, as: :json
    assert_response :not_found
  end
end
