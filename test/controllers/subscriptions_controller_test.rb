# typed: strict

require "test_helper"
require "test_helpers/testing"

class SubscriptionsControllerTest < Testing::IntegrationTest
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

    assert_response :success
  end

  teardown do
    Timecop.return
  end

  test "should get index" do
    subscription = Subscription.new(product: products(:monthly), user_id: @user_id)
    subscription.save

    get "/subscriptions", headers: { Authorization: "Bearer #{@token}" }, as: :json
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

    get "/subscriptions", as: :json
    assert_response :unauthorized
  end

  test "should not create subscription when unauthorized" do
    product = products(:monthly)

    post "/subscriptions", params: {
      subscription: { product_id: product.id }
    }, as: :json

    assert_response :unauthorized

    expected_subscriptions = [ *subscriptions ]
    actual_subscriptions = Subscription.all

    assert_equal expected_subscriptions.to_json, actual_subscriptions.to_json
  end


  test "should create subscription" do
    product = products(:monthly)

    post "/subscriptions", params: {
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
    get subscription_url(subscription.id), headers: { Authorization: "Bearer #{@token}" }, as: :json
    assert_response :forbidden
  end

  test "should show own subscription" do
    subscription = Subscription.new(user_id: @user_id, product: products(:monthly))
    subscription.save

    get subscription_url(subscription.id), headers: { Authorization: "Bearer #{@token}" }, as: :json
    assert_response :success

    assert_equal({
      "id" => subscription.id,
      "created_at" => "1990-01-01T00:00:00.000Z",
      "product_id" => products(:monthly).id,
      "user_id" => @user_id
    }, response.parsed_body)
  end

  test "can't show when doesn't exist" do
    subscription = subscriptions(:basic_subscription)
    get subscription_url(10000), headers: { Authorization: "Bearer #{@token}" }, as: :json
    assert_response :not_found
  end
end
