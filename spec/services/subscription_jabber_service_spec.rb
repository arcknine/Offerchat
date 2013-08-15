require 'spec_helper'

describe SubscriptionJabberService do
  before(:each) do
    user     = Fabricate(:user)
    website  = Fabricate(:website, :owner => user)
    @account = Fabricate(:account, :user => user, :website => website, :role => Account::OWNER)
  end

  it "should initialize class" do
    service = SubscriptionJabberService.new(@account.id)
    service.should_not be_nil
  end

  it "should subscribe rosters" do
    service = SubscriptionJabberService.new(@account.id)
    service.subscribe_rosters.should_not be_nil
  end

  it "should subscribe agents" do
    service = SubscriptionJabberService.new(@account.id)
    service.subscribe_agents.should_not be_nil
  end
end