class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user_has_website?
    @websites = current_user.all_sites
    head :unauthorized if @websites.empty?
  end

  def after_sign_in_path_for(resource)
    if resource.class.name == "User"
      if resource.trial_days_left == 0 && resource.plan_identifier == "PROTRIAL"
        "#upgrade"
      else
        root_url
      end
    elsif resource.class.name == "Admin"
      "/admins"
    end
  end
end
