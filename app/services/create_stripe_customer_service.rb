class CreateStripeCustomerService
  def initialize(user, plan, card_token)
    @user, @plan, @card = user, plan, card_token
  end

  def create
    if valid?
      customer = Stripe::Customer.create :description => @user.name, :email => @user.email, :plan => @plan.plan_identifier, :card => @card
      @user.update_attribute(:stripe_customer_token, customer.id)
    end
  rescue
    errors.add :base, "There was a problem with your credit card."
    false
  end

  def upgrade
    stripe = Stripe::Customer.retrieve @user.stripe_customer_token
    stripe.update_subscription :plan => @plan.plan_identifier, :prorate => true
  end
end
