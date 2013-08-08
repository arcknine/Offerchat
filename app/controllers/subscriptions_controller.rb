class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def create
    @user = current_user

    plan = params[:plan_id]
    card_token = params[:card_token]

    unless @user.stripe_customer_token.nil?
      stripe = CreateStripeCustomerService.new(@user, plan, card_token)
      stripe.upgrade
    else
      stripe = CreateStripeCustomerService.new(@user, plan, card_token)
      stripe.create
    end
  end
end
