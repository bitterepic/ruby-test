# typed: strict

require "test_helper"
require "test_helpers/testing"

class ProductsControllerTest < Testing::IntegrationTest
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
    new_product = Product.new(name: "test product")
    new_product.save
    previous_products = Product.all.to_a

    get v1_products_path, headers: { Authorization: "Bearer #{@token}" }, as: :json
    assert_response :success
    assert_equal({
      "products" => [ previous_products[0].as_json, {
        "id" => new_product.id,
        "created_at" => "1990-01-01T00:00:00.000Z",
        "name" => "test product"
      }
    ] }, response.parsed_body)
  end

  test "should not return index when not authorized" do
    product = Product.new(name: "test product")
    product.save

    get v1_products_path, as: :json
    assert_response :unauthorized
  end
end
