require 'spec_helper'

describe OpenfireApi do
  before(:each) do
    @user  = Fabricate(:user)
    @user2 = Fabricate(:user)
  end

  it "should generate jabber account" do
    OpenfireApi.create_user(@user.jabber_user, @user.jabber_password).should eq(true)
  end

  it "should add roster" do
    # create 2nd account to be added as roster to 1st jabber account
    OpenfireApi.create_user(@user2.jabber_user, @user2.jabber_password).should eq(true)

    # user is subscribed to user2
    OpenfireApi.subcribe_roster(@user2.jabber_user, @user.jabber_user, "test name", "test group").should eq(true)

    # user2 is subscribed to user
    OpenfireApi.subcribe_roster(@user.jabber_user, @user2.jabber_user, "test name", "test group").should eq(true)
  end
end
