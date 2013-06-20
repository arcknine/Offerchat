class SignupWizardController < ApplicationController
  include Wicked::Wizard

  steps :step_one, :step_two, :step_three, :step_four, :step_five

  def show
    case step.to_s
      when 'step_one'
        unless user_signed_in?
          @user = User.new
        else
          redirect_to root_path
        end
      when 'step_two'
        @user = User.new
      when 'step_three'
        @user = current_user
        @website = Website.new
      when 'step_four'
        @user = current_user
        @website = Website.where(:owner => current_user)
      when 'step_five'
        @user = current_user
        @website = Website.where(:owner => current_user)
    else

    end
    render_wizard
  end

  def create

    case step.to_s
      when 'step_one'
        session[:user] = {:email => params[:user]['email'] }
        redirect_to signup_wizard_path('step_two')

      when 'step_three'
        @website = Website.new
        @website.url = params[:website]['url']
        @website.owner_id = current_user.id
        if @website.save
          redirect_to signup_wizard_path('step_four')
        else
          redirect_to(signup_wizard_path('step_four'), :notice => 'Please select a website that you own')
        end
    else

    end
  end
end

