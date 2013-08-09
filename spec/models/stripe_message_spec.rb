require 'spec_helper'

describe StripeMessage do
  it "should parse string response to JSON" do
    msg = Fabricate(:stripe_message)
    msg.data_to_json.class.should eq(Hash)
    msg.previous_attributes_to_json.class.should eq(Hash)
  end
end
