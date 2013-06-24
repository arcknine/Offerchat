require 'spec_helper'

describe Website do

  it { should have_many(:accounts) }
  it { should have_many(:rosters) }
  it { should belong_to(:owner) }

  describe "website creation" do
    before(:each) do
      @website = Fabricate(:website)
    end

    it "should have url" do
      @website.url.should_not be_nil
      @website.url.should_not be_blank
    end

    it "should have name" do
      @website.name.should_not be_nil
      @website.name.should_not be_blank
    end

    it { should_not allow_value("teststringforurl").for(:url) }
    it { should_not allow_value("http://localhost").for(:url) }
    it { should allow_value("http://www.nice-url.com").for(:url) }

    it "should have default settings" do
      @website.settings(:style).should_not be_blank
      @website.settings(:style).theme.should_not be_empty
      @website.settings(:style).position.should_not be_empty
      @website.settings(:style).rounded.should_not be_nil
      @website.settings(:style).gradient.should_not be_nil

      @website.settings(:online).header.should_not be_blank
      @website.settings(:online).agent_label.should_not be_blank
      @website.settings(:online).greeting.should_not be_blank
      @website.settings(:online).placeholder.should_not be_blank

      @website.settings(:pre_chat).enabled.should_not be_nil
      @website.settings(:pre_chat).message_required.should_not be_nil
      @website.settings(:pre_chat).header.should_not be_blank
      @website.settings(:pre_chat).description.should_not be_blank

      @website.settings(:post_chat).enabled.should_not be_nil
      @website.settings(:post_chat).header.should_not be_blank
      @website.settings(:post_chat).description.should_not be_blank

      @website.settings(:offline).enabled.should_not be_nil
      @website.settings(:offline).header.should_not be_blank
      @website.settings(:offline).description.should_not be_blank
    end

    it "should have api key" do
      @website.api_key.should_not be_nil
    end
  end

  describe "after create" do
    before(:each) do
      @website = Fabricate(:website)
    end

    it "should generate API key" do
      @website.api_key.should_not be_nil
      @website.api_key.should_not be_blank
    end

    it "should create a new account" do
      @website.accounts.count.should eq(1)
    end

    it "should generate 1 job to create 30 rosters for website owner" do
      expect {
        Fabricate(:website)
      }.to change(GenerateRostersWorker.jobs, :size).by(1)
    end
  end

  it "#agents" do
    owner   = Fabricate(:user)
    website = Fabricate(:website, :owner => owner)
    Fabricate(:account, :user => Fabricate(:user), :website => website, :role => Account::AGENT)
    Fabricate(:account, :user => Fabricate(:user), :website => website, :role => Account::AGENT)
    Fabricate(:account, :user => Fabricate(:user), :website => website, :role => Account::ADMIN)

    website.agents.count.should eq(3)
    website.agents.each do |a|
      a.should_not be_nil
      a.account(website.id).role.should_not eq(Account::OWNER)
    end
  end

  describe "when running methods from sidekiq" do
    it "should generate correct visitor id for website" do
      @website = Fabricate(:website)
      @website.generate_visitor_id.should =~ /^visitor_[0-9]*_\d{6}/
    end
  end
end
