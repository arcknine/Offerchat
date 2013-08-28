Stripe.api_key    = ENV["STRIPE_API_KEY"]
STRIPE_PUBLIC_KEY = ENV["STRIPE_PUBLIC_KEY"]

StripeEvent.setup do
  subscribe do |event|
    StripeMessage.create(:event_id => event.id, :created => event.created, :livemode => event.livemode, :data => event.data, :previous_attributes => event.previous_attributes)
  end
end
