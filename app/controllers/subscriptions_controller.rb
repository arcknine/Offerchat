class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def create
    @user = current_user

    plan       = params[:plan_id]
    card_token = params[:card_token]
    # agents     = params[:agents]s
    coupon     = params[:coupon]
    qty        = params[:qty]

    stripe = CreateStripeCustomerService.new(@user, plan, card_token, coupon, qty)

    MIXPANEL.track(@user.email, "Upgrade Plan", {
      "Old Plan" => @user.plan_identifier,
      "New Plan" => @user.plan
    })

    if @user.stripe_customer_token.blank?
      stripe.create
    else
      stripe.upgrade
    end
  end
end
