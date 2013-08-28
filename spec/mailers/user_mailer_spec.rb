require "spec_helper"

describe UserMailer do
  it "should send an email to the added old user agent" do
    password = Devise.friendly_token[0,8]
    user    = Fabricate(:user, password: password, password_confirmation: password)
    website = Fabricate(:website, :owner => user)
    account = Fabricate(:account, :website => website, :user => user, :role => Account::OWNER)
    agent   = Fabricate(:user)
    UserMailer.new_agent_welcome(account, agent, password).deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end
  
  it "should send an email to the newly added user" do
    user    = Fabricate(:user)
    website = Fabricate(:website, :owner => user)
    account = Fabricate(:account, :website => website, :user => user, :role => Account::OWNER)
    agent   = Fabricate(:user)
    UserMailer.old_agent_welcome(account, agent).deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end
end
