require "spec_helper"

describe WidgetMailer do
  it "should send an email when the agents are offline" do
    password = Devise.friendly_token[0,8]
    user    = Fabricate(:user, password: password, password_confirmation: password)
    website = Fabricate(:website, :owner => user)
    to = website.settings(:offline).email
    WidgetMailer.offline_form(to, "tester name", 'test@test.com', "body").deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end

  it "should send an email when it is a post chat form" do
    password = Devise.friendly_token[0,8]
    user    = Fabricate(:user, password: password, password_confirmation: password)
    website = Fabricate(:website, :owner => user)
    to = website.settings(:offline).email
    WidgetMailer.offline_form(to, "tester name", 'test@test.com', "body").deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end


end
