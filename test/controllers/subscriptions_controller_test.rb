# typed: strict

require "test_helper"
require "test_helpers/testing"

class SubscriptionsControllerTest < Testing::IntegrationTest
  extend T::Sig

  test "should get index" do
    get "/subscriptions", as: :json
    assert_response :success
      assert_equal subscriptions.as_json, response.parsed_body
  end

  test "should create subscription" do
   user = users(:john_smith)
   product = products(:basic_subscription)
 
   assert_difference("Subscription.count") do
      post "/subscriptions", params: {
       subscription: { user_id: user.id, product_id: product.id }
     }, as: :json
   end

   assert_response :created

   expected_subscriptions = [ *subscriptions, {
           id: response.parsed_body[:id],
           product_id: product.id,
           user_id: user.id
   } ]
   actual_subscriptions = Subscription.all

   assert_equal expected_subscriptions.to_json, actual_subscriptions.to_json
  end

  test "should show subscription" do
    subscription = subscriptions(:basic_subscription)
    get subscription_url(subscription.id), as: :json
    assert_response :success
  end

  # test "should update subscription" do
  #   patch subscription_url(@subscription), params: { subscription: { name: @subscription.name } }, as: :json
  #   assert_response :success
  # end

  test "should destroy subscription" do
    subscription = subscriptions(:basic_subscription)
    assert_difference("Subscription.count", -1) do
      delete subscription_url(subscription.id), as: :json
    end

    assert_response :no_content
  end
end
