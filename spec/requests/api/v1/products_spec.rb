require 'swagger_helper'

describe 'api/v1/products', type: :request do
  path '/v1/products' do
    get 'Get available products' do
      tags 'Products'
      consumes 'application/json'
      security [ Bearer: {} ]
      description %Q(
A type representing products that can be subscribed to.
      )
      response '200', 'Returns all products' do
        let(:"authorization") { "Bearer #{token_for(user)}" }
        example 'application/json', :success, {
          "products": [
            {
              "id": 1,
              "name": "com.samansa.subscription.monthly",
              "created_at": "2026-04-04T12:39:23.954Z"
            }
          ]
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        example 'application/json', :success, {
          "message": "Please log in"
        }
        run_test!
      end
    end
  end
end
