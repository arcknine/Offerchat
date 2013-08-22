class ExportersController < ApplicationController
  def index
    if params[:data].present?
      jsonArray = params[:data]
      objArray = JSON.parse(jsonArray)
      @content = ''
      objArray.each do |msg|
        @content += "(#{msg['time']}) #{msg['sender']}: #{msg['message']} \r\n"
      end
    end
    send_data @content,
      :type => 'text',
      :disposition => "attachment; filename=offerchat_chat_logs.txt"
  end
end
