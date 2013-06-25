class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user_has_website?
    head :unauthorized if current_user.websites.empty?
  end
end
