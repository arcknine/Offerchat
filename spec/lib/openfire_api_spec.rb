require 'spec_helper'

describe OpenfireApi do
  before(:each) do
    @user  = Fabricate(:user)
    @user2 = Fabricate(:user)
  end

  it "should return true on create user" do
    OpenfireApi.create_user(@user.jabber_user, @user.jabber_password).should eq(true)
  end

  it "should return true on subscribe roster" do
    OpenfireApi.subcribe_roster(@user2.jabber_user, @user.jabber_user, "test name", "test group").should eq(true)
  end
end