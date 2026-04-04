# typed: true

class V1::NotFoundController < ApplicationController
  def show
    raise NotFoundError.new
  end
end
