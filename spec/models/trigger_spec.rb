require 'spec_helper'

describe Trigger do

  it { should belong_to :website }
  it { should serialize :params }
  it { should validate_presence_of :message }
  it { should validate_presence_of :rule_type }
  it { should validate_presence_of :params }

  describe "trigger creation" do

    before(:each) do
      @trigger = Fabricate(:trigger)
    end

    it "should have params" do
      @trigger.params.should_not be_nil
      @trigger.params.should_not be_blank
    end

    it "should have rule type" do
      @trigger.rule_type.should_not be_nil
      @trigger.rule_type.should_not be_blank
    end

    it "should have message" do
      @trigger.message.should_not be_nil
      @trigger.message.should_not be_blank
    end

  end

end
