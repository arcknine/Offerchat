class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user_has_website?
    @websites = current_user.all_sites
    head :unauthorized if @websites.empty?
  end
    
  def after_sign_in_path_for(resource)
    if resource.class.name == "User"
      root_url
    elsif resource.class.name == "Admin"
      "/admins"
    end
  end
end
