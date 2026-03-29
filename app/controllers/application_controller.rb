# typed: strict

class ApplicationController < ActionController::API
  before_action :authorized

  extend T::Sig

  sig { void }
  def initialize
    @user = T.let(nil, T.nilable(User))
  end

  sig { params(payload: T.untyped).returns(String) }
  def encode_token(payload)
    JWT.encode({data: payload, exp: Time.now.to_i + 4 * 3600 }, hmac_secret, 'HS256')
  end

  sig { returns(T.untyped) }
  def decoded_token
    header = request.headers["Authorization"]
    if header
      token = header.split(" ")[1]
      begin
        JWT.decode(token, hmac_secret, true, { algorithm: 'HS256' }))
      rescue JWT::DecodeError
        nil
      end
    end
  end

  sig { returns(T.untyped) }
  def current_user
    if decoded_token
      user_id = decoded_token[0]["user_id"]
      @user = User.find_by(id: user_id)
    end
  end

  sig { returns(T::Boolean) }
  def authorized
    unless !!current_user
      render json: { message: "Please log in" }, status: :unauthorized
    end
  end
end
