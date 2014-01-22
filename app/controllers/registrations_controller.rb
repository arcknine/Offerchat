class RegistrationsController < Devise::RegistrationsController

  def create
    params[:user][:display_name] = params[:user][:name].split(" ").first
    params[:user][:plan_identifier] = "PROTRIAL"

    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        # Create user's first website
        website = CreateWebsiteService.new(resource)
        website.create
        # Sign in
        sign_in(resource_name, resource)
        # Vero & Mixpanel
        current_user.track("Signup")

        MIXPANEL.track "Enter User Info", {
          :distinct_id => current_user.email
        }
        MIXPANEL.set current_user, { :name => current_user.name, :jabber_user => current_user.jabber_user,
          :plan => current_user.plan_identifier, :created => current_user.created_at, :email => current_user.email }

        redirect_to signup_wizard_path('step_two')
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

    signup_wizard_path('step_one')
  end

end
