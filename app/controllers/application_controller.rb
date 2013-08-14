class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user_has_website?
    @websites = current_user.all_sites
    head :unauthorized if @websites.empty?
  end

end
