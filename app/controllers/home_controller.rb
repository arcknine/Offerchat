class HomeController < ApplicationController
   before_filter :authenticate_user!

  def index
    @user         = current_user
    gon.chat_info = { :bosh_url => ENV["CHAT_BOSH_URL"], :server_name => ENV["CHAT_SERVER_NAME"] }
    gon.history_url = ENV["CHAT_HISTORY_URL"]
    gon.current_user = current_user
    gon.trial_days_left = current_user.trial_days_left

    redirect_to "/rails_admin" if current_admin
  end
end
