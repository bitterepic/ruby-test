# typed: strict

require "test_helper"
require "test_helpers/testing"
require "timecop"
require_relative "../../app/controllers/concerns/json_web_token"

class AuthenticationControllerTest < Testing::IntegrationTest
  extend T::Sig

  setup do
    @token = T.let("", String)

    # Create the user
    Timecop.freeze(DateTime.new(1990).utc) do
      post "/register", params: {
        email: "test@example.com",
        family_name: "test family name",
        given_name: "test given name",
        password: "012345678"
      }, as: :json
    end

    assert_response :success
    assert_equal(
      {
        "user" => {
          "id" => 1,
          "created_at" => "1990-01-01T00:00:00.000Z",
          "email" => "test@example.com",
          "family_name" => "test family name",
          "given_name" => "test given name",
          "roles" => []
        }
      },
      response.parsed_body)
  end

  test "registers a user and can login" do
    Timecop.freeze(DateTime.new(1991).utc) do
      post "/login", params: {
        email: "test@example.com",
        password: "012345678"
      }, as: :json

      assert_response :success

      token = response.parsed_body.as_json["token"]

      assert_equal(JsonWebToken.decode(token),
        [{"data" => {"id" => 1}, "exp" => 662702400}, {"alg" => "HS256"}]
      )
    end
  end

  test "registers a user and login expired" do
    Timecop.freeze(DateTime.new(1991).utc) do
      post "/login", params: {
        email: "test@example.com",
        password: "012345678"
      }, as: :json

      assert_response :success

      @token = response.parsed_body.as_json["token"]
    end

    Timecop.freeze(DateTime.new(1992).utc) do
      assert_nil(JsonWebToken.decode(@token))
    end
  end
end
