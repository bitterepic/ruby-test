# typed: strict

class ApplicationController < ActionController::API
  before_action :ensure_authenticated

  rescue_from UnauthenticatedError, with: :handle_unauthorized_error
  rescue_from ForbiddenError, with: :handle_forbidden_error
  rescue_from NotFoundError, with: :handle_not_found_error

  extend T::Sig

  sig { returns(String) }
  def hmac_secret
    out = T.let(Rails.application.credentials[:hmac_secret], T.nilable(String))
    throw "hmac_secret is unset in Rails Credentials.  Please add it" if out.nil?
    out
  end

  sig { void }
  def initialize
    @user = T.let(nil, T.nilable(User))
  end

  sig { returns(User) }
  def authenticated_user
    throw UnauthenticatedError if @user.nil?
    @user
  end

  sig { returns(T::Boolean) }
  def ensure_authenticated
    unless !!load_user
      render json: { message: "Please log in" }, status: :unauthorized
    end
  end

  private

  sig { params(payload: T.untyped).returns(String) }
  def encode_token(payload)
    JsonWebToken.encode({ data: payload, exp: Time.now.to_i + 4 * 3600 })
  end

  sig { returns(T.untyped) }
  def decode_token
    header = request.headers["Authorization"]
    if header
      token = header.split(" ")[1]
      begin
        JsonWebToken.decode(token)
      rescue JWT::DecodeError
        nil
      end
    end
  end

  sig { returns(T.untyped) }
  def load_user
    payload = decode_token
    if payload
      user_id = payload[0]["user_id"]
      @user = User.find_by(id: user_id)
    end
  end

  sig { params(exception: StandardError, message: String, status: Symbol).returns(String) }
  def handle_error(exception, message, status)
    backtrace = exception.backtrace
    backtraceString = backtrace.join("\n") if !backtrace.nil?

    Rails.logger.error "ERROR: #{self.class.name} #{exception.class.name}: #{exception}", backtraceString

    render json: { message: }, status:
  end

  sig { params(exception: UnauthenticatedError).returns(String) }
  def handle_unauthorized_error(exception)
    handle_error(exception, "Unauthenticated", :unauthorized)
  end

  sig { params(exception: ForbiddenError).returns(String) }
  def handle_forbidden_error(exception)
    handle_error(exception, "Forbidden", :forbidden)
  end

  sig { params(exception: NotFoundError).returns(String) }
  def handle_not_found_error(exception)
    handle_error(exception, "Not Found", :not_found)
  end
end
