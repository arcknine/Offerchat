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

  describe "Account functions" do
    before(:each) do
      @owner = Fabricate(:user)
      @website = Fabricate(:website, :owner => @owner)
      @account = [{ "role" => Account::AGENT, "website_id" => @website.id }]
    end

    let(:valid_user_post) do

    end

     it "#create_or_invite_agents" do
      user = Fabricate(:user)
      result = User.create_or_invite_agents(user, @account)
      result.should eq(user)
    end

    it "should return agents under my account" do
      user = Fabricate(:user)
      User.create_or_invite_agents(user, @account)

      @owner.my_agents.each do |a|
        a.account(@website.id).role.should_not eq(Account::OWNER)
      end
    end

    it "should return as pending" do
      user = Fabricate(:user)
      User.create_or_invite_agents(user, @account)
      user.pending?.should eq(true)
    end
  end
end
