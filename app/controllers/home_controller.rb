class HomeController < ApplicationController
   before_filter :authenticate_user!

  def index
    @user         = current_user
    gon.chat_info = { :bosh_url => ENV["CHAT_BOSH_URL"], :server_name => ENV["CHAT_SERVER_NAME"] }
    gon.current_user = current_user
    # gon.rabl "app/views/users/show.rabl", as: "current_user"
  end
end
