require 'open-uri'

class TranscriptController < ApplicationController

  def show
    token = params[:id]

    url = "#{ENV["CHAT_HISTORY_URL"]}chats/#{token}.json"

    response = open(url).read
    objArray = JSON.parse(response)
    content = ''
    objArray.each do |msg|
      sender = msg['sender'] == 'visitor' ? 'You' : 'Agent'
      sent_date = DateTime.parse(msg['sent']).strftime("%m/%d/%Y %H:%M %p")
      content += "(#{sent_date}) #{sender}: #{msg['msg']} \r\n"
    end

    send_data content,
      :type => 'text',
      :disposition => "attachment; filename=offerchat-#{token}.txt"
  end


  def email_export
    if params[:email].present? && params[:messages].present? && validate_email(params[:email].to_s)
      UserMailer.delay.send_transcript( params[:email].to_s, params[:messages].html_safe )
      render json: { success: {"success" => ["email sent!"]} }, status: 200
    else
      render json: { errors: {"email" => ["should be valid and not blank"]} }, status: 401
    end
  end


  private
  def validate_email(email)
    email_regex = %r{
      ^ # Start of string
      [0-9a-z] # First character
      [0-9a-z.+]+ # Middle characters
      [0-9a-z] # Last character
      @ # Separating @ character
      [0-9a-z] # Domain name begin
      [0-9a-z.-]+ # Domain name middle
      [0-9a-z] # Domain name end
      $ # End of string
    }xi # Case insensitive

    if (email =~ email_regex) == 0
      return true
    else
      return false
    end
  end


end
