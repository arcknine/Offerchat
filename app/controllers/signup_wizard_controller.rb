class SignupWizardController < ApplicationController
  include Wicked::Wizard
  before_filter :check_restrictions
  steps :step_one, :step_two, :step_three, :step_four, :step_five

  def show
    case step
    when :step_one
      @user = User.new
    when :step_two
      if session[:user][:email]
        @user = User.new
      else
        redirect_to signup_wizard_path('step_one')
      end
    when :step_three
      @website = Website.new
    when :step_four
      @website = Website.where(:owner_id => current_user.id).last
      if @website.nil?
        redirect_to signup_wizard_path('step_three')
      end
    when :step_five
      @website = Website.where(:owner_id => current_user.id).last
      if @website.nil?
        redirect_to signup_wizard_path('step_three')
      end
    end
    render_wizard
  end

  def update
    case step
    when :step_one
      @user = User.find_by_email(params[:user]['email'])
      if @user.nil?
        session[:user] = {:email => params[:user]['email'] }
        redirect_to signup_wizard_path('step_two')
      else
        redirect_to signup_wizard_path('step_one'), :notice => 'Email already exist'
      end

    when :step_three
      @website = Website.new
      @website.url = params[:website]['url']
      @website.owner_id = current_user.id
      if @website.save
        redirect_to signup_wizard_path('step_four')
      else
        redirect_to signup_wizard_path('step_three'), :notice => 'Please select a website that you own'
      end

    when :step_four
      @website = Website.where(:owner_id => current_user.id).last
      @website.settings(:style).theme = params[:settings]['theme']
      @website.settings(:style).position = params[:settings]['position']
      if @website.save
        redirect_to signup_wizard_path('step_five')
      else
        redirect_to signup_wizard_path('step_four'), :notice => 'Something went wrong!'
      end
    end
  end

  private

  def check_restrictions
    case step
    when :step_one, :step_two
      if user_signed_in?
        redirect_to signup_wizard_path('step_three')
      end
    when :step_three, :step_four, :step_five
      authenticate_user!
    end
  end

end

