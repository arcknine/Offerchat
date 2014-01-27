class HomeController < ApplicationController
  before_filter :authenticate_user!
  include Vero::DSL

  def index
    @user         = current_user
    gon.chat_info = { :bosh_url => ENV["CHAT_BOSH_URL"], :server_name => ENV["CHAT_SERVER_NAME"] }
    gon.history_url = ENV["CHAT_HISTORY_URL"]
    gon.current_user = current_user
    gon.trial_days_left = current_user.trial_days_left

    # Update user on vero & mixpanel
    vero.users.edit_user!({ :email => current_user.email, :changes => { :trial_days_left => current_user.trial_days_left, :widget_installed => current_user.widget_installed }})
    MIXPANEL.people.set(current_user.email, {
      'Plan'             => current_user.plan_identifier,
      'Trial days left'  => current_user.trial_days_left
    })

    redirect_to "/rails_admin" if current_admin
  end
end
