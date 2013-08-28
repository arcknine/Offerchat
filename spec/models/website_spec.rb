require 'spec_helper'

describe Website do

  it { should have_many(:accounts) }
  it { should have_many(:rosters) }
  it { should belong_to(:owner) }

  it { should validate_presence_of :name }

  describe "website creation" do
    before(:each) do
      @website = Fabricate(:website, :owner => Fabricate(:user))
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
      @website = Fabricate(:website, :owner => Fabricate(:user))
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
        Fabricate(:website, :owner => Fabricate(:user))
      }.to change(GenerateRostersWorker.jobs, :size).by(1)
    end

    it "should create an api drip worker" do
      expect{
        Fabricate(:website, :owner=>Fabricate(:user))
      }.to change(DripWorker.jobs, :size).by(1)
    end

    describe "settings" do

      it "offline email should be equal to owner email" do
        @website.settings(:offline).email.should_not be_nil
        @website.settings(:offline).email.should eq(@website.owner.email)
      end

      it "post_chat email should be equal to owner email" do
        @website.settings(:post_chat).email.should_not be_nil
        @website.settings(:post_chat).email.should eq @website.owner.email
      end

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

  it "#owner_and_agents" do
    owner   = Fabricate(:user)
    website = Fabricate(:website, :owner => owner)
    Fabricate(:account, :user => Fabricate(:user), :website => website, :role => Account::AGENT)
    Fabricate(:account, :user => Fabricate(:user), :website => website, :role => Account::AGENT)
    Fabricate(:account, :user => Fabricate(:user), :website => website, :role => Account::ADMIN)

    website.owner_and_agents.count.should eq(4)
    website.owner_and_agents.should include(owner)
  end

  describe "when running methods from sidekiq" do
    it "should generate correct visitor id for website" do
      @website = Fabricate(:website, :owner => Fabricate(:user))
      @website.generate_visitor_id.should =~ /^visitor_[0-9]*_\d{6}/
    end
  end

  describe "after delete of website" do
    before(:each) do
      @website = Fabricate(:website, :owner => Fabricate(:user))
      Fabricate(:account, :website => @website)
    end

    it "should also delete accounts" do
      @website.destroy
      @website.accounts.should be_empty
    end
  end

  describe "when updating website settings" do
    before(:each) do
      @website = Fabricate(:website, :owner => Fabricate(:user))
    end

    it "should update settings based on the parameters" do
      settings = {"style"=>{"theme"=>"cadmiumreddeep", "position"=>"right", "rounded"=>false, "gradient"=>true},
      "online"=>{"header"=>"Chat with us", "agent_label"=>"Got a question? We can help.", "greeting"=>"Hi, I am",
      "placeholder"=>"Type your message and hit enter"}, "pre_chat"=>{"enabled"=>false, "message_required"=>false,
      "header"=>"Let me get to know you!", "description"=>"Fill out the form to start the chat."}, "post_chat"=>{"enabled"=>true,
      "header"=>"Chat with me, I'm here to help", "description"=>"Please take a moment to rate this chat session"},
      "offline"=>{"enabled"=>true, "header"=>"Contact Us", "description"=>"Leave a message and we will get back to you ASAP."}}

      @website.save_settings(settings)

      @website.settings(:style).theme.should eq("cadmiumreddeep")
      @website.settings(:style).gradient.should be_true
    end

    describe "online" do
      it "should not allow blanks on website label" do
        settings = {"style"=>{"theme"=>"cadmiumreddeep", "position"=>"right", "rounded"=>false, "gradient"=>true},
          "online"=>{"header"=>"Chat with us", "agent_label"=>"", "greeting"=>"Hi, I am",
          "placeholder"=>"Type your message and hit enter"}, "pre_chat"=>{"enabled"=>false, "message_required"=>false,
          "header"=>"Let me get to know you!", "description"=>"Fill out the form to start the chat."}, "post_chat"=>{"enabled"=>true,
          "header"=>"Chat with me, I'm here to help", "description"=>"Please take a moment to rate this chat session"},
          "offline"=>{"enabled"=>true, "header"=>"Contact Us", "description"=>"Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP."}}

        @website.save_settings(settings)
        @website.errors.should_not be_blank
      end
    end

    describe "offline" do
      it "description should be less than 140 characters" do
        settings = {"style"=>{"theme"=>"cadmiumreddeep", "position"=>"right", "rounded"=>false, "gradient"=>true},
          "online"=>{"header"=>"Chat with us", "agent_label"=>"Got a question? We can help.", "greeting"=>"Hi, I am",
          "placeholder"=>"Type your message and hit enter"}, "pre_chat"=>{"enabled"=>false, "message_required"=>false,
          "header"=>"Let me get to know you!", "description"=>"Fill out the form to start the chat."}, "post_chat"=>{"enabled"=>true,
          "header"=>"Chat with me, I'm here to help", "description"=>"Please take a moment to rate this chat session"},
          "offline"=>{"enabled"=>true, "header"=>"Contact Us", "description"=>"Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP.Leave a message and we will get back to you ASAP."}}

        @website.save_settings(settings)
        @website.errors.messages.should_not be_blank
      end

      it "email should be valid format" do
        settings = {"style"=>{"theme"=>"cadmiumreddeep", "position"=>"right", "rounded"=>false, "gradient"=>true},
        "online"=>{"header"=>"Chat with us", "agent_label"=>"Got a question? We can help.", "greeting"=>"Hi, I am",
        "placeholder"=>"Type your message and hit enter"}, "pre_chat"=>{"enabled"=>false, "message_required"=>false,
        "header"=>"Let me get to know you!", "description"=>"Fill out the form to start the chat."}, "post_chat"=>{"enabled"=>true,
        "header"=>"Chat with me, I'm here to help", "description"=>"Please take a moment to rate this chat session"},
        "offline"=>{"enabled"=>true, "header"=>"Contact Us", "description"=>"Leave a message and we will get back to you ASAP.", "email" => "erapguapo"}}

        @website.save_settings(settings)
        @website.errors.messages.should_not be_blank
      end
    end

    describe "prechat" do
      it "should not allow empty description" do
        settings = {
          "style" => {"theme"=>"cadmiumreddeep", "position"=>"right", "rounded"=>false, "gradient"=>true},
          "online" => {"header"=>"Chat with us", "agent_label"=>"Got a question? We can help.", "greeting"=>"Hi, I am","placeholder"=>"Type your message and hit enter"},
          "pre_chat" => {"enabled"=>false, "message_required"=>false,"header"=>"Let me get to know you!", "description"=>""},
          "post_chat" => {"enabled"=>true,"header"=>"Chat with me, I'm here to help", "description"=>"Please take a moment to rate this chat session"},
          "offline" => {"enabled"=>true, "header"=>"Contact Us", "description"=>"Leave a message and we will get back to you ASAP.", "email" => "erapguapo@erap.com"}
        }
        @website.save_settings(settings)
        @website.errors.messages.should_not be_blank
      end

      it "should not allow more than 140 characters for description" do
        settings = {
            "style" => {"theme"=>"cadmiumreddeep","position"=>"right","rounded"=>false,"gradient"=>true},
            "online" => {"header"=>"Chat with us","agent_label"=>"Got a question? We can help.","greeting"=>"Hi, I am","placeholder"=>"Type your message and hit enter"},
            "pre_chat" => {"enabled"=>false,"message_required"=>false,"header"=>"Let me get to know you!","description"=>"description description description description description description description description description description description description description description description description description description "},
            "post_chat" => {"enabled"=>true,"header"=>"Chat with me, I'm here to help", "description"=>"Please take a moment to rate this chat session"},
            "offline" => {"enabled"=>true,"header"=>"Contact Us","description"=>"Leave a message and we will get back to you ASAP.","email" => "erapguapo@erap.com"}
        }
        @website.save_settings(settings)
        @website.errors.messages.should_not be_blank
      end

      it "email should be valid format" do
        settings = {"style"=>{"theme"=>"cadmiumreddeep", "position"=>"right", "rounded"=>false, "gradient"=>true},
        "online"=>{"header"=>"Chat with us", "agent_label"=>"Got a question? We can help.", "greeting"=>"Hi, I am",
        "placeholder"=>"Type your message and hit enter"}, "pre_chat"=>{"enabled"=>false, "message_required"=>false,
        "header"=>"Let me get to know you!", "description"=>"Fill out the form to start the chat."}, "post_chat"=>{"enabled"=>true,
        "header"=>"Chat with me, I'm here to help", "description"=>"Please take a moment to rate this chat session"},
        "offline"=>{"enabled"=>true, "header"=>"Contact Us", "description"=>"Leave a message and we will get back to you ASAP.", "email" => "erapguapo"}}
        @website.save_settings(settings)

        @website.errors.messages.should_not be_blank
      end
    end

    describe "post_chat" do
      it "should not allow empty description" do
        settings = {
          "style" => {"theme"=>"cadmiumreddeep", "position"=>"right", "rounded"=>false, "gradient"=>true},
          "online" => {"header"=>"Chat with us", "agent_label"=>"Got a question? We can help.", "greeting"=>"Hi, I am","placeholder"=>"Type your message and hit enter"},
          "pre_chat" => {"enabled"=>false, "message_required"=>false,"header"=>"Let me get to know you!", "description"=>"asdfasdfadfasdfasdfasdfasdfa"},
          "post_chat" => {"enabled"=>true,"header"=>"Chat with me, I'm here to help", "description"=>""},
          "offline" => {"enabled"=>true, "header"=>"Contact Us", "description"=>"Leave a message and we will get back to you ASAP.", "email" => "erapguapo@erap.com"}
        }
        @website.save_settings(settings)
        @website.errors.messages.should_not be_blank
      end

      it "should not allow more than 140 characters for description" do
        settings = {
            "style" => {"theme"=>"cadmiumreddeep","position"=>"right","rounded"=>false,"gradient"=>true},
            "online" => {"header"=>"Chat with us","agent_label"=>"Got a question? We can help.","greeting"=>"Hi, I am","placeholder"=>"Type your message and hit enter"},
            "pre_chat" => {"enabled"=>false,"message_required"=>false,"header"=>"Let me get to know you!","description"=>"descsdfsdf asdfasdf"},
            "post_chat" => {"enabled"=>true,"header"=>"Chat with me, I'm here to help", "description"=>"Please take a moment to rate this chat session Please take a moment to rate this chat session Please take a moment to rate this chat session Please take a moment to rate this chat session Please take a moment to rate this chat session Please take a moment to rate this chat session"},
            "offline" => {"enabled"=>true,"header"=>"Contact Us","description"=>"Leave a message and we will get back to you ASAP.","email" => "erapguapo@erap.com"}
        }
        @website.save_settings(settings)
        @website.errors.messages.should_not be_blank
      end
    end
  end
end
