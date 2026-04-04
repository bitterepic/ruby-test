# typed: strict

class V1::SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[ show ]

  extend T::Sig

  sig { void }
  def initialize
    @subscription = T.let(nil, T.nilable(Subscription))
  end

  # GET /subscriptions
  sig { returns(String) }
  def index
    subscriptions = T.let(Subscription.where(user_id: authenticated_user.id).to_a, T::Array[Subscription])

    render json: { subscriptions: }
  end

  # GET /subscriptions/1
  sig { returns(String) }
  def show
    last_transaction = subscription.transactions.order(created_at: :asc).select(
      :id,
      :action,
      :created_at,
      :currency,
      :expires_date,
      :external_id,
      :purchase_date,
      :source
    ).last.as_json

    render json: { subscription: { **subscription.as_json, last_transaction: }  }
  end

  # POST /subscriptions
  sig { returns(String) }
  def create
    new_subscription = Subscription.new({ **subscription_params, user_id: authenticated_user.id })

    if new_subscription.save
      render json: { subscription: new_subscription }, status: :created, location: v1_subscription_path(new_subscription.id)
    else
      render json: { errors: new_subscription.errors }, status: :unprocessable_content
    end
  end

  private
    sig { void }
    def set_subscription
      out = Subscription.where(id: params.expect(:id)).first
      raise ForbiddenError.new if out && out.user_id != authenticated_user.id
      @subscription = out
    end

    sig { returns(Subscription) }
    def subscription
      out = @subscription

      raise NotFoundError.new if out.nil?
      out
    end

    sig { returns(ActionController::Parameters) }
    def subscription_params
      params.expect(subscription: [ :product_id ])
    end
end
