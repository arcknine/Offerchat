class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def create
    @user = current_user

    plan       = params[:plan_id]
    card_token = params[:card_token]
    agents     = params[:agents]
    coupon     = params[:coupon]

    stripe = CreateStripeCustomerService.new(@user, plan, card_token, coupon)
    if @user.stripe_customer_token.blank?
      stripe.create
    else
      # stripe = CreateStripeCustomerService.new(@user, plan, card_token)
      stripe.upgrade
    end

    unless agents.blank?
      agent_list = UnassignAgentsService.new(agents, @user)
      agent_list.unassign
    end
  end
end