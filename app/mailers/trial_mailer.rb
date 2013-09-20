class TrialMailer < ActionMailer::Base
  default from: "no-reply@offerchat.com"

  def five_days_remaining(user)
    @user = user
    mail(:to => user.email, :subject => "Your Offerchat new user login!")
  end

  def three_days_remaining(user)
    @user = user
    mail(:to => user.email, :subject => "Your Offerchat new user login!")
  end

  def one_day_remaining(user)
    @user = user
    mail(:to => user.email, :subject => "Your Offerchat new user login!")
  end
end
