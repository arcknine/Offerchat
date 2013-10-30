class CreateStripeCustomerService
  def initialize(user, plan, card_token, coupon)
    @user, @plan, @card, @coupon = user, plan, card_token, coupon
  end

  def create
    customer = Stripe::Customer.create :description => @user.name, :email => @user.email, :plan => @plan, :card => @card, :coupon => @coupon
    @user.update_attributes(:stripe_customer_token => customer.id, :plan_identifier => @plan)
  rescue => errors
    puts errors.inspect
    false
  end

  def upgrade
    stripe = Stripe::Customer.retrieve @user.stripe_customer_token
    stripe.update_subscription :plan => @plan, :prorate => true, :coupon => @coupon
    @user.update_attribute(:plan_identifier, @plan)
  end
end
