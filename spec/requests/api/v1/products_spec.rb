require 'swagger_helper'

describe 'api/v1/products', type: :request do
  path '/v1/products' do
    get 'Create a product' do
      tags 'Product'
      consumes 'application/json'
      security [Bearer: {}]

      response '200', 'Returns all products' do
        let(:"Authorization") { "Bearer #{token_for(user)}" }
        example 'application/json', :success, {
          "user": []
        }
        run_test!
      end
    end
  end
end
