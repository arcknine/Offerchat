require "spec_helper"

describe UserMailer do
  it "should send an email to the newly added user" do
    user    = Fabricate(:user)
    website = Fabricate(:website, :owner => user)
    account = Fabricate(:account, :website => website, :user => user, :role => Account::OWNER)
    agent   = Fabricate(:user)
    UserMailer.agent_welcome(account, agent).deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end
end
