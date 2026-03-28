# typed: false

class SubscriptionsController < ApplicationController
  extend T::Sig

  before_action :set_subscription, only: %i[ show update destroy ]

  sig { void }
  def initialize
    @subscription = T.let(Subscription.new, Subscription)
  end


  # GET /subscriptions
  sig { returns(String) }
  def index
    puts "INDEX"
    puts(Subscription.all, Subscription::PrivateRelation)
    subscriptions = T.let(Subscription.all, Subscription::PrivateRelation)

    render json: subscriptions
  end

  # GET /subscriptions/1
  sig { returns(String) }
  def show
    puts "SHOW"
    render json: @subscription
  end

  # POST /subscriptions
  sig { returns(String) }
  def create
    @subscription = Subscription.new(subscription_params)
    puts @subscription.to_json

    if @subscription.save
      render json: @subscription, status: :created, location: @subscription
    else
      render json: @subscription.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /subscriptions/1
  sig { returns(String) }
  def update
    if @subscription.update(subscription_params)
      render json: @subscription
    else
      render json: @subscription.errors, status: :unprocessable_content
    end
  end

  # DELETE /subscriptions/1
  sig { returns(Integer) }
  def destroy
    @subscription.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    sig { void }
    def set_subscription
      @subscription = Subscription.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    sig { void }
    def subscription_params
      params.expect(subscription: [ :user_id, :product_id ])
    end
end
