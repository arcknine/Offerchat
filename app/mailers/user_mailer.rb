class UserMailer < ActionMailer::Base
  default from: "Offerchat Notifications <hello@offerchat.com>"

  def registration_welcome(email)
    mail(:to => email, :subject => "Welcome to Offerchat Site")
  end

  def new_agent_welcome(account, agent, password)
    @account, @agent, @password = account, agent, password
    mail(:to => @agent.email, :subject => "Your Offerchat new user login!")
  end

  def old_agent_welcome(account, agent)
    @account, @agent = account, agent
    mail(:to => @agent.email, :subject => "Your assigned website")
  end

  def send_to_webmaster(email, name, apikey)
    @website = Website.find_by_api_key(apikey)
    mail(:to => email, :subject => "Offerchat Website Integration Code")
  end

  def migrate_owner(email,password,token)
    @email, @password, @token = email, password, token
    mail(:to => email, :subject => "Offerchat Account Migration to new Dashboard")
  end

  def send_transcript(email,message)
    @message = message
    mail(:to => email, :subject => "Offerchat Transcript Export")
  end

  def welcome_code(user_id)
    @user = User.find(user_id)
    @website = @user.websites.first
    mail(:to => @user.email, :subject => "Welcome to Offerchat!")
  end
end
