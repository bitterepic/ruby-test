require 'swagger_helper'

describe 'api/v1/subscriptions', type: :request do
  path '/v1/subscriptions/{id}' do
    get 'Retrieves a subscription' do
      produces 'application/json', 'application/xml'
      parameter name: 'id', in: :path, type: :string
      tags 'Subscriptions'
      consumes 'application/json'
      security [ Bearer: {} ]

      response '200', "Returns the user's subscription detail" do
        let(:"Authorization") { "Bearer #{token_for(user)}" }
        example 'application/json', :success, {
          "subscription": {
            "id": 1,
            "user_id": 1,
            "product_id": 1,
            "created_at": "2026-04-04T12:53:09.007Z",
            "last_transaction": {
              "id": 1,
              "action": "purchase",
              "created_at": "2026-04-04T13:21:00.691Z",
              "currency": "USD",
              "expires_date": "1990-02-01T12:00:00.000Z",
              "external_id": "4d249252-118d-42c6-99b8-75ded060ceea",
              "purchase_date": "1990-01-01T00:01:00.000Z",
              "source": "apple"
            }
          }
        }
        run_test!
      end

      response '404', 'Not Found' do
        example 'application/json', :success, {
          "message": "Not Found"
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

  path '/v1/subscriptions' do
    get 'Get all subscriptions for the user' do
      produces 'application/json', 'application/xml'
      tags 'Subscriptions'
      consumes 'application/json'
      security [ Bearer: {} ]

      response '200', 'Returns all subscriptions for the user' do
        let(:"Authorization") { "Bearer #{token_for(user)}" }
        example 'application/json', :success, {
          "subscriptions": [
            {
              "id": 1,
              "user_id": 1,
              "product_id": 1,
              "created_at": "2026-04-04T12:53:09.007Z"
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

    post 'Create a subscription for the user' do
      tags 'Subscriptions'
      consumes 'application/json'
      security [ Bearer: {} ]
      request_body_example value: {
        product_id: 1
      },
      name: "Create a subscription",
      summary: "A request example"
      parameter name: 'body', in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :number }
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
