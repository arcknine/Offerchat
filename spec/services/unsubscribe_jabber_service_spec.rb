require 'spec_helper'

describe UnsubscribeJabberService do
  before(:each) do
    user     = Fabricate(:user)
    website  = Fabricate(:website, :owner => user)
    @account = Fabricate(:account, :user => user, :website => website, :role => Account::OWNER)
  end

  it "should initialize class" do
    service = UnsubscribeJabberService.new(@account.user_id, @account.website_id)
    service.should_not be_nil
  end

  it "should unsubscribe rosters" do
    service = UnsubscribeJabberService.new(@account.user_id, @account.website_id)
    service.unsubscribe_rosters.should_not be_nil
  end

  it "should unsubscribe agents" do
    service = UnsubscribeJabberService.new(@account.user_id, @account.website_id)
    service.unsubscribe_agents.should_not be_nil
  end
end