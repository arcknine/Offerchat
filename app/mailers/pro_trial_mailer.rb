class ProTrialMailer < ActionMailer::Base
  default from: "no-reply@offerchat.com"

  def five_days_remaining(user)
    @user = user
    mail(:to => user.email, :subject => "5 more days before your Pro Trial ends")
  end

  def three_days_remaining(user)
    @user = user
    mail(:to => user.email, :subject => "3 more days before Pro Trial ends")
  end

  def one_day_remaining(user)
    @user = user
    mail(:to => user.email, :subject => "1 more day left and your Pro Trial is no more", :from => "vincent@offerchat.com")
  end
end
