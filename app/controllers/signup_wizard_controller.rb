class SignupWizardController < ApplicationController
  include Wicked::Wizard
  before_filter :check_restrictions
  steps :step_one, :step_two, :step_three, :step_four, :step_five
  respond_to :json
  def index

  end

  def show
    case step
    when :step_one
      # email
      @user = User.new
      render_wizard
    when :step_two
      # name and password
      session[:user] ||= {:email => nil}
      unless session[:user][:email].nil?
        @user = User.new
        render_wizard
      else
        redirect_to signup_wizard_path('step_one')
      end
    when :step_three
      # website url
      @website = Website.new
      render_wizard
    when :step_four
      # update website settings position & theme
      @website = Website.where(:owner_id => current_user.id).last
      if @website.nil?
        redirect_to signup_wizard_path('step_three')
      else
        render_wizard
      end
    when :step_five
      # show api key code
      @website = Website.where(:owner_id => current_user.id).last
      if @website.nil?
        redirect_to signup_wizard_path('step_three')
      else
        render_wizard
      end
    end
  end

  def update
    case step
    when :step_one
      unless is_a_valid_email?(params[:user]['email'])
        flash[:alert] = 'Email should be valid'
        redirect_to signup_wizard_path('step_one')
      else
        @user = User.find_by_email(params[:user]['email'])
        if @user.nil?
          session[:user] = {:email => params[:user]['email'] }
          redirect_to signup_wizard_path('step_two')
        else
          redirect_to signup_wizard_path('step_one'), :alert => 'Email already exist'
        end
      end

    when :step_three
      @website = Website.new
      @website.url = params['url']
      # @website.owner_id = current_user.id
      session[:website] = {:url => params['url'] }
      unless @website.valid?
        respond_with @website
      else
        head :no_content
      end




    when :step_four
      @website = Website.where(:owner_id => current_user.id).last
      @website.settings(:style).theme = params[:settings]['theme']
      @website.settings(:style).position = params[:settings]['position']
      if @website.save
        redirect_to signup_wizard_path('step_five')
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

  def is_a_valid_email?(email)
    unless email.nil? || email.empty?
      if email =~ /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i then
        return true
      else
        return false
      end
    else
      return false
    end
  end


end

