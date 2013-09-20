class TrialMailer < ActionMailer::Base
  default from: "no-reply@offerchat.com"

  def five_days_remaining(user)
    @user = user
    mail(:to => user.email, :subject => "5 more days before your Premium Trial ends")
  end

  def three_days_remaining(user)
    @user = user
    mail(:to => user.email, :subject => "3 more days before Premium Trial ends")
  end

  def one_day_remaining(user)
    @user = user
    mail(:to => user.email, :subject => "1 more day left and you're Premium Trial is no more")
  end
end
