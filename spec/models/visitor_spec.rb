require 'spec_helper'

describe Visitor do
  it { should have_many(:notes) }

  describe "after create" do
    before(:each) do
      @website = Fabricate(:website, :owner => Fabricate(:user))
      @visitor = Fabricate(:visitor, :website_id => @website.id)
    end

    it "should generate a token" do
      @visitor.token.should_not be_blank
    end
  end
end