class RegistrationsController < Devise::RegistrationsController

  def create
    params[:user][:email] = session[:user][:email]
    build_resource

    if resource.save
      if resource.active_for_authentication?
        UserMailer.delay.registration_welcome(params[:user][:email])
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        # redirect_to ( root_path('#websites/new') )
        redirect_to :controller => :home, :action=>:index, :anchor => "website/new"
        #redirect_to root_path, :anchor => '#step_three'

      end
    else
      clean_up_passwords resource
      respond_with({}, :location => after_sign_up_fails_path_for(resource)) # edit redirect to signup page
    end
  end

  def after_sign_up_fails_path_for(resource)
    resource.errors.full_messages.each do |item|
      flash[:alert] = item
    end
    signup_wizard_path('step_two')
  end

end
