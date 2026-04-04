# typed: true

class V1::NotFoundController < ApplicationController
  def show
    if @user.nil?
      raise UnauthorizedError.new
    end

    raise NotFoundError.new
  end
end
