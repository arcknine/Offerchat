class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def registration_welcome()

    mail(:to => 'wiredots01@yahoo.com.ph', :subject => "Welcome to My Awesome Site")
  end

end
