# typed: strict

#
module Testing
  LoginResponseType = T.type_alias { {
    created_at: String,
    family_name: String,
    given_name: String,
    id: Integer,
    token: String
  } }

  RegisterResponseType = T.type_alias { {
    user: {
      created_at: String,
      email: String,
      family_name: String,
      given_name: String,
      id: Integer,
      roles: T::Array[String]
    }
  } }

  class NotInitializedError < StandardError
    extend T::Sig

    sig { params(msg: String).void }
    def initialize(msg = "Value has not been initialized yet.")
      super(msg)
    end
  end

  class IntegrationTest < ActionDispatch::IntegrationTest
    extend T::Sig

    sig { params(arg: T.untyped).void }
    def initialize(arg)
      super(arg)

      @response = T.let(nil, T.nilable(ActionDispatch::TestResponse))
      @request = T.let(nil, T.nilable(ActionDispatch::TestRequest))
      @token = T.let("", String)
      @user_id = T.let(-1, Integer)
    end

    # A typed request that will never be nil
    sig { returns(ActionDispatch::TestRequest) }
    def request
      throw NotInitializedError.new if @request == nil

      @request
    end

    # A typed response that will never be nil
    sig { returns(ActionDispatch::TestResponse) }
    def response
      throw NotInitializedError.new if @response == nil

      @response
    end

    # Create the user
    sig { params(
      email: String,
      family_name: String,
      given_name:
      String, password: String
    ).returns(RegisterResponseType) }
    def register(
      email = "test@example.com",
      family_name = "test family name",
      given_name = "test given name",
      password = "012345678"
    )
      out = post "/v1/register", params: {
        email:,
        family_name:,
        given_name:,
        password:
      }, as: :json

      assert_response :success

      response.parsed_body => {
        user: {
          created_at:,
          email:,
          family_name:,
          given_name:,
          id:,
          roles:
        }
      }

      {
        user: {
          created_at:,
          email:,
          family_name:,
          given_name:,
          id:,
          roles:
        }
      }
    end

    sig { params(email: String, password: String).returns(LoginResponseType) }
    def login(email = "test@example.com", password = "012345678")
      out = post "/v1/login", params: {
        email:,
        password:
      }, as: :json

      @token = response.parsed_body["token"]
      @user_id = response.parsed_body["id"]

      assert_response :success
      response.parsed_body => {
        created_at:,
        family_name:,
        given_name:,
        id:,
        token:
      }

      {
        created_at:,
        family_name:,
        given_name:,
        id:,
        token:
      }
    end
  end
end
