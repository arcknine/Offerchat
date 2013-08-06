class CreateStripeCustomerService
  def initialize(user, plan, card_token)
    @user, @plan, @card = user, plan, card_token
  end

  def create
    customer = Stripe::Customer.create :description => @user.name, :email => @user.email, :plan => @plan, :card => @card
    @user.update_attributes(:stripe_customer_token => customer.id, :plan_identifier => @plan)
  rescue => errors
    puts errors.inspect
    false
  end

  def upgrade
    stripe = Stripe::Customer.retrieve @user.stripe_customer_token
    stripe.update_subscription :plan => @plan, :prorate => true
    @user.update_attribute(:plan_identifier, @plan)
  end
end
