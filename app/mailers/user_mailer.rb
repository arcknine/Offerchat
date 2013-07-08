class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def registration_welcome(email)
    mail(:to => email, :subject => "Welcome to Offerchat Site")
  end

  def agent_welcome(account, agent)
    @account, @agent = account, agent
    mail(:to => @account.website.owner.email, :subject => "You've been added to Offerchat!")
  end
end
