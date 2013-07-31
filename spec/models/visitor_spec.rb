require 'spec_helper'

describe "after create" do
  before(:each) do
    @visitor = Fabricate(:visitor, :website => Fabricate(:website))
  end

  it "should generate a token" do
    @visitor.token.should_not be_blank
  end
end
