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
    vero.users.edit_user!({ :email => current_user.email, :changes => { :trial_days_left => current_user.trial_days_left,
                            :widget_installed => current_user.widget_installed, :trial_type => current_user.trial_type }})
    MIXPANEL.people.set(current_user.email, {
      'Plan'             => current_user.plan_identifier,
      'Website'          => current_user.first_website_url,
      'Trial days left'  => current_user.trial_days_left
    })

    redirect_to "/rails_admin" if current_admin
  end

  def become
    return unless current_user.email == "jkennedy@offerchat.com"
    sign_in(:user, User.find(params[:id]))
    redirect_to root_url
  end
end
