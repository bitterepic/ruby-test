require 'swagger_helper'

describe 'api/v1/authentication', type: :request do
  path '/v1/register' do
    post 'Creates a blog' do
      tags 'Register'
      consumes 'application/json'
      request_body_example value: {
          email: "test@example.com",
          password: "0123456789",
          given_name: "example given name",
          family_name: "example family name"
        },
        name: 'Register a user',
        summary: 'A request example'
      parameter name: 'body', in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          given_name: { type: :string },
          family_name: { type: :string }
        },
        required: [ 'email', 'password', 'given_name', 'family_name' ]
      }

      response '201', 'user registered' do
        example 'application/json', :success, {
          "user": {
            "created_at": "2026-04-04T02:18:40.116Z",
            "email": "test@example.com",
            "family_name": "example family name",
            "given_name": "example given name",
            "id": 1,
            "roles": []
          }
        }
        run_test!
      end

      response '422', 'user exists' do
        example 'application/json', :success, {
          "error": [
            "Email has already been taken"
          ]
        }
        run_test!
      end
    end
  end

  path '/v1/login' do
    post 'Logs in a user' do
      tags 'Login'
      consumes 'application/json'
      request_body_example value: {
          email: "test@example.com",
          password: "0123456789",
        },
        name: 'Login a user',
        summary: 'Returns the user\'s information and an authorization token. It should be passed as the bairer token to other authorized requests.'
      parameter name: 'body', in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          given_name: { type: :string },
          family_name: { type: :string }
        },
        required: [ 'email', 'password' ]
      }

      response '200', 'Login succeeded' do
        example 'application/json', :success, {
          "token": "eyJhbGciOiJIUzI1NiJ9.eyJkYXRhIjp7ImlkIjoxfSwiZXhwIjoxNzc1Mjg2MjEwfQ.e1HbNox2aIGH8aqPIBAYPbwAiAX_Xck-ju9la95KwNg",
          "user": {
            "created_at": "2026-04-04T02:18:40.116Z",
            "email": "test@example.com",
            "family_name": "example family name",
            "given_name": "example given name",
            "id": 1,
            "roles": []
          }
        }
        run_test!
      end

      response '401', 'Login failed' do
        example 'application/json', :success, {
          "message": "Unauthorized"
        },
        run_test!
      end
    end
  end
end
