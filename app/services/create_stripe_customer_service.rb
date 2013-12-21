class CreateStripeCustomerService
  def initialize(user, plan, card_token, coupon, qty)
    @user, @plan, @card, @coupon, @qty = user, plan, card_token, coupon, qty
  end

  def create
    customer = Stripe::Customer.create :description => @user.name, :email => @user.email, :plan => @plan, :card => @card, :coupon => @coupon, :quantity => @qty
    @user.update_attributes(:stripe_customer_token => customer.id, :plan_identifier => @plan)
  rescue => errors
    puts errors.inspect
    false
  end

  def upgrade
    stripe = Stripe::Customer.retrieve @user.stripe_customer_token
    stripe.update_subscription :plan => @plan, :prorate => true, :coupon => @coupon, :quantity => @qty
    @user.update_attribute(:plan_identifier, @plan)
  end
end
