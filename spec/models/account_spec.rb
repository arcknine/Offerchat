require 'spec_helper'

describe Account do

  it { should belong_to :website }
  it { should belong_to :user }

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
  end
end
