class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[ show update destroy ]

  # GET /subscriptions
  def index
    @subscriptions = Subscription.all

    render json: @subscriptions
    sdfd
  end

  # GET /subscriptions/1
  def show
    render json: @subscription
  end

  # POST /subscriptions
  def create
    puts "FISH"
    @subscription = Subscription.new(subscription_params)
    puts @subscription.to_json

    if @subscription.save
      render json: @subscription, status: :created, location: @subscription
    else
      render json: @subscription.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /subscriptions/1
  def update
    if @subscription.update(subscription_params)
      render json: @subscription
    else
      render json: @subscription.errors, status: :unprocessable_content
    end
  end

  # DELETE /subscriptions/1
  def destroy
    @subscription.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription
      @subscription = Subscription.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def subscription_params
      params.expect(subscription: [ :user_id, :product_id ])
    end
end
