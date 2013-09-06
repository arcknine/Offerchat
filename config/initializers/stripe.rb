Stripe.api_key    = ENV["STRIPE_API_KEY"]
STRIPE_PUBLIC_KEY = ENV["STRIPE_PUBLIC_KEY"]

StripeEvent.setup do
  subscribe do |event|
    s = StripeMessage.new
    s.event_id            = event.id
    s.created             = event.created
    s.livemod             = event.livemode
    s.data                = event.data
    begin
      s.previous_attributes = event.previous_attributes
    rescue
      s.previous_attributes = nil
    end
    s.save
  end
end
