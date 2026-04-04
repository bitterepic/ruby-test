require 'swagger_helper'

describe 'api/v1/subscriptions', type: :request do
  path '/v1/subscriptions' do
    get 'Get all subscriptions for the user' do
      tags 'Subscriptions'
      consumes 'application/json'
      security [Bearer: {}]

      response '200', 'Returns all subscriptions for the user' do
        let(:"Authorization") { "Bearer #{token_for(user)}" }
        example 'application/json', :success, {
          "subscriptions": [
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

    post 'Create a subscription for the user' do
      tags 'Subscription'
      consumes 'application/json'
      security [Bearer: {}]
      request_body_example value: {
        product_id: 1
      },
      name: "Create a subscription",
      summary: "A request example"
      parameter name: 'body', in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :number },
        },
        required: [ 'product_id' ]
      }

      response '201', 'Subscription created' do
        let(:"Authorization") { "Bearer #{token_for(user)}" }
        example 'application/json', :success, {
          subscription: {
            "id": 1,
            "user_id": 1,
            "product_id": 1,
            "created_at": "2026-04-04T12:53:09.007Z"
          }
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        example 'application/json', :success, {
          "message": "Please log in"
        }
        run_test!
      end

      response '422', 'Creation failed' do
        example 'application/json', :success, {
          "errors": {
            "product": [
              "must exist"
            ]
          }
        }
        run_test!
      end
    end
  end
end
