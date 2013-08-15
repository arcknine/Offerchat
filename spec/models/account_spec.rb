require 'spec_helper'

describe Account do

  it { should belong_to :website }
  it { should belong_to :user }

  describe "Account functions" do
    it "#is_owner?" do
      owner = Fabricate(:account, :role => Account::OWNER)
      owner.is_owner?.should eq(true)
    end

    it "#is_admin?" do
      owner = Fabricate(:account, :role => Account::ADMIN)
      owner.is_admin?.should eq(true)
    end

    it "#is_agent?" do
      owner = Fabricate(:account, :role => Account::AGENT)
      owner.is_agent?.should eq(true)
    end
  end

  describe "after create of account for admin or agent" do
    before(:each) do
      owner    = Fabricate(:user)
      @website = Fabricate(:website, :owner => owner)
      @user    = Fabricate(:user)
    end

    it "should create rosters for agent" do
      expect {
        Fabricate(:agent, :user => @user, :website => @website)
      }.to change(SubscribeRostersWorker.jobs, :size).by(1)
    end

    it "should create rosters for admin" do
      expect {
        Fabricate(:admin, :user => @user, :website => @website)
      }.to change(SubscribeRostersWorker.jobs, :size).by(1)
    end

    it "should add existing agents to the new agent's roster" do
      Fabricate(:agent, :user => Fabricate(:user), :website => @website)
      Fabricate(:admin, :user => Fabricate(:user), :website => @website)

      expect{
        Fabricate(:agent, :user => Fabricate(:user), :website => @website)
      }.to change(AgentRostersWorker.jobs, :size).by(1)
    end

    it "should add existing agents to the new admin's roster" do
      Fabricate(:agent, :user => Fabricate(:user), :website => @website)
      Fabricate(:admin, :user => Fabricate(:user), :website => @website)

      expect{
        Fabricate(:admin, :user => Fabricate(:user), :website => @website)
      }.to change(AgentRostersWorker.jobs, :size).by(1)
    end
  end

  describe "before destroy user should be unsubscribe to visitors and agent" do
    before(:each) do
      @account  = Fabricate(:account)
    end

    it "should unsubscribe user to website rosters" do
      expect {
        @account.destroy
      }.to change(UnsubscribeRostersWorker.jobs, :size).by(1)
    end

    it "should unsubscribe user to website agents" do
      expect {
        @account.destroy
      }.to change(UnsubscribeAgentsWorker.jobs, :size).by(1)
    end
  end
end
