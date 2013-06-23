class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def registration_welcome(email)
    mail(:to => email, :subject => "Welcome to Offerchat Site")
  end

  def agent_welcome(owner, agent)
    @owner, @agent = owner, agent
    mail(:to => @owner.email, :subject => "You've been added to Offerchat!")
  end
end
