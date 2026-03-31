# typed: strict

class SubscriptionsController < ApplicationController
  before_action :ensure_authenticated, :set_subscription, only: %i[ show ]

  extend T::Sig

  sig { void }
  def initialize
    @subscription = T.let(nil, T.nilable(Subscription))
  end

  # GET /subscriptions
  sig { returns(String) }
  def index
    subscriptions = T.let(Subscription.where(user_id: authenticated_user.id).to_a, T::Array[Subscription])

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
    new_subscription = Subscription.new({ **subscription_params, user_id: authenticated_user.id })

    if new_subscription.save
      render json: new_subscription, status: :created, location: subscription_path(new_subscription.id)
    else
      render json: new_subscription.errors, status: :unprocessable_content
    end
  end

  private
    sig { void }
    def set_subscription
      @subscription = Subscription.find(params.expect(:id))
      throw ForbiddenError.new if (@subscription.user_id != authenticated_user.id)
    end

    sig { returns(Subscription) }
    def subscription
      throw NotFoundError.new if @subscription.nil?
      @subscription
    end

    sig { returns(ActionController::Parameters) }
    def subscription_params
      params.expect(subscription: [ :product_id ])
    end
end
