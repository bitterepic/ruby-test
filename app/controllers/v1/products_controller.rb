# typed: strict

class V1::ProductsController < ApplicationController
  extend T::Sig

  # GET /products
  sig { returns(String) }
  def index
    products = T.let(Product.all.to_a, T::Array[Product])

    render json: { products: }
  end
end
