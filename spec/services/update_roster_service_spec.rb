require 'spec_helper'

describe UpdateRosterService do
  before(:each) do
    user     = Fabricate(:user)
    @website = Fabricate(:website, :owner => user)
    @roster  = Fabricate(:roster, :website => @website)
    @account = Fabricate(:account, :user => user, :website => @website, :role => Account::OWNER)
    @service = UpdateRosterService.new(@roster.id, "name")
  end

  it "should initialize class" do
    @service.should_not be_nil
  end

  it "should update name" do
    @service.update_roster.count.should eq @website.owner_and_agents.count
  end
end