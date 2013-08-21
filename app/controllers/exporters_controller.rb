class ExportersController < ApplicationController
  def index
    # if params[:data].present?
    #   jsonArray = params[:data]
    #   objArray = JSON.parse(jsonArray)
    #   @content = ''
    #   objArray.each do |msg|
    #     @content += "(#{msg['time']}) #{msg['sender']}: #{msg['message']} \r\n"
    #   end
    # end
    # send_data @content,
    #   :type => 'text',
    #   :disposition => "attachment; filename=offerchat_chat_logs.txt"

    user = User.new
    user.password ='123123123'
    user.email ='xtestsdf@testasdfasdf.com'
    user.name = 'rommel esparcia'
  end
end
