# typed: strict

require "test_helper"
require "test_helpers/testing"
require "timecop"
require_relative "../../../app/controllers/concerns/json_web_token"

class AuthenticationControllerTest < Testing::IntegrationTest
  extend T::Sig

  setup do
    Timecop.freeze(DateTime.new(1990).utc)

    @token = T.let("", String)
    registerResponse = register

    assert_equal(
      {
        "user": {
          "created_at": "1990-01-01T00:00:00.000Z",
          "email": "test@example.com",
          "family_name": "test family name",
          "given_name": "test given name",
          "id": registerResponse[:user][:id],
          "roles": []
        }
      },
      registerResponse
    )

    @user_id = registerResponse[:user][:id]
  end

  teardown do
    Timecop.return
  end

  test "registers a user and can login" do
    Timecop.freeze(DateTime.new(1991).utc) do
      login

      assert_response :success

      token = response.parsed_body.as_json["token"]

      assert_equal(JsonWebToken.decode(token),
        [ { "data" => { "id" => @user_id }, "exp" => 662702400 }, { "alg" => "HS256" } ]
      )
    end
  end

  test "registers a user and login expired" do
    Timecop.freeze(DateTime.new(1991).utc) do
      login

      assert_response :success

      @token = response.parsed_body.as_json["token"]
    end

    Timecop.freeze(DateTime.new(1992).utc) do
      assert_nil(JsonWebToken.decode(@token))
    end
  end
end
