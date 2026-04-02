class V1::UsersController < ApplicationController
  skip_before_action :ensure_authenticated, only: :create

  def create
    user = User.new(user_params)
    if user.save
      render json: { user: user }, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email, :password, :username)
  end
end
