class WidgetMailer < ActionMailer::Base
  default from: "Offerchat Notifications <hello@offerchat.com>"

  def offline_form(to, name, from, message)
    @data = {:full_name => name, :from => from, :message => message }
    mail(:to => to, :subject => "Offerchat Offline Form", :reply_to => to)
  end

  def post_chat_form(to, name, from, message)
    @data = {:full_name => name, :from => from, :message => message }
    mail(:to => to, :subject => "Offerchat Post Chat Form", :reply_to => to)
  end
end
