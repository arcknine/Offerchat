require 'spec_helper'

describe StripeMessage do
  it "should parse string response to JSON" do
    msg = Fabricate(:stripe_message)

    msg.json_response.class.should eq(Hash)
  end
end
