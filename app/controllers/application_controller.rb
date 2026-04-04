# typed: strict

class ApplicationController < ActionController::API
  before_action :ensure_authenticated

  rescue_from UnauthorizedError, with: :handle_unauthorized_error
  # NOTE: As a security mechanism, forbidden errors are shown as not found responses.
  rescue_from ForbiddenError, with: :handle_not_found_error
  rescue_from NotFoundError, with: :handle_not_found_error

  extend T::Sig

  sig { returns(String) }
  def hmac_secret
    out = T.let(Rails.application.credentials[:hmac_secret], T.nilable(String))
    raise "hmac_secret is unset in Rails Credentials.  Please add it" if out.nil?
    out
  end

  sig { void }
  def initialize
    @user = T.let(nil, T.nilable(User))
  end

  # Helper for fetching a user who is guaranteed to always
  # be authenticated.  Otherwise, it shows an UnauthorizedError.
  sig { returns(User) }
  def authenticated_user
    raise UnauthorizedError if @user.nil?
    @user
  end

  # Authorization helper designed to be run in a before_action
  sig { returns(T.nilable(String)) }
  def ensure_authenticated
    unless load_user
      render json: { message: "Please log in" }, status: :unauthorized
    end
  end

  private

  # Generates a new json web token for login
  sig { params(payload: T.untyped).returns(String) }
  def encode_token(payload)
    JsonWebToken.encode({ data: payload, exp: Time.now.to_i + 4 * 3600 })
  end

  # Decodes a new json web token for verifying authentication
  sig { returns(T.untyped) }
  def decode_token
    header = request.headers["Authorization"]
    if header
      if (!header.starts_with?("Bearer "))
        throw UnauthorizedError.new("Auth token must start with 'Bearer '")
      end
      token = header.gsub(/^Bearer /, '')
      begin
        JsonWebToken.decode(token)
      rescue JWT::DecodeError
        nil
      end
    end
  end

  sig { returns(T::Boolean) }
  def load_user
    payload = decode_token
    if payload
      user_id = payload[0]["data"]["id"]
      @user = User.find(user_id)
    end
    !@user.nil?
  end

  sig { params(exception: StandardError, message: String, status: Symbol).returns(String) }
  def handle_error(exception, message, status)
    backtrace = exception.backtrace
    backtraceString = backtrace.join("\n") if !backtrace.nil?

    Rails.logger.error "ERROR: #{self.class.name} #{exception.class.name}: #{exception} ${backtraceString}"

    render json: { message: }, status:
  end

  sig { params(exception: UnauthorizedError).returns(String) }
  def handle_unauthorized_error(exception)
    handle_error(exception, "Unauthorized", :unauthorized)
  end

  sig { params(exception: StandardError).returns(String) }
  def handle_not_found_error(exception)
    handle_error(exception, "Not Found", :not_found)
  end
end
