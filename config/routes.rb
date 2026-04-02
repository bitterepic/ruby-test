# typed: true

Rails.application.routes.draw do
  namespace :v1 do
    resources :subscriptions, only: [ :index, :show, :create ]
    resources :users, only: [ :create, :show ]
    resources :apple_transactions, path: "/webhooks/apple/transactions", only: [ :create ]
  end

  get "/v1/up" => "rails/health#show", as: :rails_health_check

  post "/v1/login", to: "v1/authentication#login"
  post "/v1/register", to: "v1/authentication#register"
end
