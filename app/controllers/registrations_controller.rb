class RegistrationsController < Devise::RegistrationsController

  def create
    params[:user][:email] = session[:user][:email]
    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        redirect_to :controller => :home, :action=>:index, :anchor => "websites/new"
      end
    else
      clean_up_passwords resource
      respond_with({}, :location => after_sign_up_fails_path_for(resource)) # edit redirect to signup page
    end
  end

  def after_sign_up_fails_path_for(resource)
    resource.errors.messages.each do |key,msg|
      flash[key] = msg
    end

    signup_wizard_path('step_two')
  end

end
