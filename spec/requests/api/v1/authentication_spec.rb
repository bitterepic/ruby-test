require 'swagger_helper'

describe 'api/v1/authentication', type: :request do
  path '/register' do
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

      response '201', 'blog created' do
        example 'application/json', :example_key, {
          id: 1,
          title: 'Hello world!',
          content: '...'
        }
        example 'application/json', :example_key_2, {
          id: 1,
          title: 'Hello world!',
          content: '...'
        }, "Summary of the example", "Longer description of the example"
        let(:request_params) { { 'blog' => { title: 'foo', content: 'bar' } } }
        run_test!
      end

      # response '422', 'invalid request' do
      #  let(:request_params) { { 'blog' => { title: 'foo' } } }
      #  run_test!
      # end
    end
  end
end
