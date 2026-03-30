# typed: strict

class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[ show update destroy ]

  extend T::Sig

  sig { void }
  def initialize
    @subscription = T.let(nil, T.nilable(Subscription))
  end

  sig { returns(Subscription) }
  def subscription
    throw TypeError.new("Subscription is nil") if @subscription.nil?

    @subscription
  end

  # GET /subscriptions
  sig { returns(String) }
  def index
    subscriptions = T.let(Subscription.all.to_a, T::Array[Subscription])

    render json: subscriptions
  end

  # GET /subscriptions/1
  sig { returns(String) }
  def show
    render json: subscription
  end

  # POST /subscriptions
  sig { returns(String) }
  def create
    new_subscription = Subscription.new(subscription_params)

    if new_subscription.save
      render json: new_subscription, status: :created, location: subscription_path(new_subscription.id)
    else
      render json: new_subscription.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /subscriptions/1
  sig { returns(String) }
  def update
    if subscription.update(subscription_params)
      render json: subscription
    else
      render json: subscription.errors, status: :unprocessable_content
    end
  end

  # DELETE /subscriptions/1
  sig { void }
  def destroy
    subscription.destroy!
  end

  private
    sig { void }
    def set_subscription
      @subscription = Subscription.find(params.expect(:id))
    end

    sig { returns(ActionController::Parameters) }
    def subscription_params
      params.expect(subscription: [ :user_id, :product_id ])
    end
end
