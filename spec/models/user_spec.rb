require 'spec_helper'

describe User do

  before(:each) do
    @user = Fabricate(:user)
  end

  it { should have_many :accounts }
  it { should have_many :websites }
  #it { should have_attached_file(:avatar) }
  #it { should validate_attachment_content_type(:avatar).allowing("image/jpg", "image/jpeg", "image/png").rejecting('text/plain', 'text/xml') }
  #it { should validate_attachment_size(:avatar).less_than(1.megabyte) }

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

    describe "on email notifications" do
      before(:each) do
        @website = Fabricate(:website)
      end

      context "and adding a new user as an agent" do
        it "should enqueue the welcome email to sidekiq" do
          expect {
            account = [{ :role => Account::AGENT, :website_id => @website.id }]
            user = Fabricate(:user)
            User.create_or_invite_agents(user, account)
          }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
        end
      end

      context "and adding a new user as an admin" do
        it "should enqueue the welcome email to sidekiq" do
          expect {
            account = [{ :role => Account::ADMIN, :website_id => @website.id }]
            user = Fabricate(:user)
            User.create_or_invite_agents(user, account)
          }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
        end
      end

      context "and adding an existing user as an admin" do
        it "should enqueue the welcome email to sidekiq" do
          expect {
            account = [{ :role => Account::ADMIN, :website_id => @website.id }]
            user = { :email => "#{Random.rand(11)}user@email.com" }
            User.create_or_invite_agents(user, account)
          }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
        end
      end

      context "and adding an existing user as an agent" do
        it "should enqueue the welcome email to sidekiq" do
          expect {
            account = [{ :role => Account::AGENT, :website_id => @website.id }]
            user = { :email => "#{Random.rand(11)}user@email.com" }
            User.create_or_invite_agents(user, account)
          }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
        end
      end
    end
  end

  describe "User Registration" do
    it "should be able to signup with valid data" do
      user = Fabricate(:user)
      expect{
        UserMailer.should_receive(:deliver_registration_welcome).with(user.email)
      }
    end

    it "should have email address" do
      @user.email.should_not be_blank
      @user.email.should_not be_nil
    end

    it "should have a name" do
      @user.name.should_not be_blank
      @user.name.should_not be_nil
      @user.name.length.should <= 25
    end

    it "should have a display name" do
      @user.display_name.should_not be_blank
      @user.display_name.should_not be_nil
      @user.display_name.length.should <= 25
    end


    it "should have a default display name" do
      @user.display_name.should_not be_blank
      @user.display_name.should_not be_nil
      @user.display_name.length.should <= 15
    end


    it "should only have an avatar of valid image type" do
      @user.avatar = File.new(Rails.root + 'spec/support/images/avatar.png')
      @user.save
      @user.avatar.should_not be_nil
    end

    it "should not accept image of invalid file types" do
      expect{
        @user.avatar = File.new(Rails.root + 'spec/support/images/avatar.pdf')
        @user.save
      }.to raise_exception
    end
  end

  describe "User functions" do
    before(:each) do
      @owner = Fabricate(:user)
      @website = Fabricate(:website, :owner => @owner)
      @account = [{ "is_admin" => true, "website_id" => @website.id }]
    end

    it "#create_or_invite_agents with an existing user"  do
      user = Fabricate(:user)
      result = User.create_or_invite_agents(user, @account)
      result.should eq(user)
    end

    it "#create_or_invite_agents with a new user" do
      user = { :email => "#{Random.rand(11)}user@email.com" }
      result = User.create_or_invite_agents(user, @account)
      result.email.should eq(user[:email])
    end

    it "#update_roles_and_websites" do
      user = Fabricate(:user)
      account = Fabricate(:account, :user => user, :website => @website, :role => Account::ADMIN)
      account = [{ "is_admin" => true, "website_id" => @website.id, "account_id" => account.id }]

      expect {
        User.update_roles_and_websites(user.id, account)
      }.to_not change(Account, :count)
    end

    it "should return agents under my account" do
      user = Fabricate(:user)
      User.create_or_invite_agents(user, @account)

      @owner.my_agents.each do |a|
        a.account(@website.id).role.should_not eq(Account::OWNER)
      end
    end

    it "should return all agents including the owner" do
      user = Fabricate(:user)
      User.create_or_invite_agents(user, @account)

      @owner.agents.should_not be_empty
      @owner.agents.should_not be_nil
      # @owner.my_agents.each do |a|
      #   a.account(@website.id).role.should_not eq(Account::OWNER)
      # end
    end

    # it "should return as pending" do
    #   user = Fabricate(:user)
    #   User.create_or_invite_agents(user, @account)
    #   user.pending?.should eq(true)
    # end
  end
end
