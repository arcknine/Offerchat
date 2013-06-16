require 'spec_helper'

describe User do
  before(:each) do
    @user = Fabricate(:user)
  end

  describe "when creating a new user" do
    it "should have a jabber_user and jabber_password ready" do
      @user.jabber_user.should_not eq(nil)
      @user.jabber_password.should_not eq(nil)
    end

    it "should process an API request to Openfire to sidekiq" do
      expect {
        Fabricate(:user)
      }.to change(JabberUserWorker.jobs, :size).by(1)
    end
  end
end
