require 'open-uri'

class TranscriptController < ApplicationController

  def show
    token = params[:id]

    url = "#{ENV["CHAT_HISTORY_URL"]}chats/#{token}"

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

end
