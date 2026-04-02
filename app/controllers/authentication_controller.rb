# typed: true

require_relative "concerns/json_web_token"

class AuthenticationController < ApplicationController
  skip_before_action :ensure_authenticated

  def login
    user_params = params.permit(:email, :password)
    user = User.where(email: params[:email]).first

    if user&.authenticate(params[:password])
      token = encode_token({ id: user.id })
      render json: { token: token, **user.as_json }, status: :ok
    else
      raise ForbiddenError.new
    end
  end

  def register
    user_params = params.permit(
      :email,
      :password,
      :given_name,
      :family_name
    )
    user = User.new({ **user_params, roles: [] })

    if user.save
      render json: { user: user.as_json(only: [
        :created_at,
        :email,
        :family_name,
        :given_name,
        :id,
        :roles
      ]) }, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
end
