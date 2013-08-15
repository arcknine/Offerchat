class UserMailer < ActionMailer::Base
  default from: "Offercha Notifications <hello@offerchat.com>"

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

  def send_to_webmaster(email, api_key)
    mail(:to => email, :subject => "Offerchat Website Integration Code")
  end
end
