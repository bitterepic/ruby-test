# typed: true

Rails.application.routes.draw do
  resources :subscriptions, only: [ :index, :show, :create ]
  resources :users, only: [ :create, :show ]
  resources :apple_transactions, path: "/webhooks/apple/transactions", only: [ :create ]

  get "up" => "rails/health#show", as: :rails_health_check
  post "/auth/login", to: "auth#login"
end
