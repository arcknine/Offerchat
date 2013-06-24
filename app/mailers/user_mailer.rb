class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def registration_welcome(email)
    mail(:to => email, :subject => "Welcome to Offerchat Site")
  end

end
