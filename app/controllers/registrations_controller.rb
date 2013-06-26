class RegistrationsController < Devise::RegistrationsController

  def create
    params[:user][:email] = session[:user][:email]
    build_resource

    if resource.save
      if resource.active_for_authentication?
        UserMailer.delay.registration_welcome(params[:user][:email])

        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        puts "been here"
        redirect_to ( signup_wizard_path('step_three') )

        # respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
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
    # "#{root_path}signup"
    signup_wizard_path('step_two')
  end

end
