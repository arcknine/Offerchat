require 'spec_helper'

describe "after create" do
  before(:each) do
    @website = Fabricate(:website, :owner => Fabricate(:user))
    @visitor = Fabricate(:visitor, :website_id => @website.id)
    @chatSession = Fabricate(:chat_session, :visitor_id => @visitor.id)
  end

  it "should make visitor logs" do
    @chatSession.visitor_id.should_not be_blank
  end
end
