require 'spec_helper'

describe Website do

  it { should have_many(:accounts) }
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
    it "should create a new account" do
      expect {
        Fabricate(:website)
      }.to change { Account.all.count }.by(1)
    end
  end
end
