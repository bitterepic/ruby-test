# typed: strict

class V1::ProductsController < ApplicationController
  extend T::Sig

  # GET /products
  sig { returns(String) }
  def index
    offset = params[:offset].nil? ? 0 : params[:offset].to_i || 0
    limit = params[:limit].nil? ? 20 : params[:limit].to_i
    query = Product.all
    result = query.offset(offset).limit(limit)
    products = T.let(result.to_a, T::Array[Product])
    count = query.count

    render json: { products:, limit:, offset:, count: }
  end
end
