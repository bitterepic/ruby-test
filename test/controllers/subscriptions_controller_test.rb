# typed: strict

require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  extend T::Sig

  sig { void }
  def initialize
    @subscription = T.let(Subscription.new, Subscription)
    @user = T.let(User.new, User)
    @product = T.let(Product.new, Product)
    @response = T.let(nil, T.untyped)
  end

  setup do
    @subscription = subscriptions(:basic_subscription)
    @user = users(:john_smith)
    @product = products(:basic_subscription)
  end

  test "should get index" do
    get "/subscriptions", as: :json
    assert_response :success
    assert_equal subscriptions.as_json, response.parsed_body
  end

  test "should create subscription" do
    assert_difference("Subscription.count") do
       post "/subscriptions", params: {
        subscription: { user_id: @user.id, product_id: @product.id }
      }, as: :json
    end

    assert_response :created

    expected_subscriptions = [ *subscriptions, {
            id: @response.parsed_body[:id],
            product_id: @product.id,
            user_id: @user.id
    } ]
    actual_subscriptions = Subscription.all

    assert_equal expected_subscriptions.to_json, actual_subscriptions.to_json
  end

  # test "should show subscription" do
  #  get subscription_url(@subscription), as: :json
  #  assert_response :success
  # end

  # test "should update subscription" do
  #  patch subscription_url(@subscription), params: { subscription: { name: @subscription.name } }, as: :json
  #  assert_response :success
  # end

  # test "should destroy subscription" do
  #  assert_difference("Subscription.count", -1) do
  #    delete subscription_url(@subscription), as: :json
  #  end

  #  assert_response :no_content
  # end
end
