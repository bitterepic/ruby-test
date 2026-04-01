# typed: true

require "jwt"

module JsonWebToken
  extend T::Sig

  sig { returns(T.nilable(String)) }
  def self.hmac_secret
    out = Rails.application.credentials[:hmac_secret]
  end

  sig { params(payload: T.untyped).returns(String) }
  def self.encode(payload)
    JWT.encode(payload, hmac_secret, "HS256")
  end

  sig { params(payload: String).returns(T.untyped) }
  def self.decode(payload)
    begin
      JWT.decode(payload, hmac_secret, true, { algorithm: "HS256" })
    rescue JWT::DecodeError =>e
      nil
    end
  end
end
