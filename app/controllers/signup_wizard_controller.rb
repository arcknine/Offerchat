class SignupWizardController < ApplicationController
  include Wicked::Wizard
  before_filter :check_restrictions
  steps :step_one, :step_two, :dashboard, :step_three, :step_four, :step_five
  respond_to :json

  def show
    case step
    when :step_one
      # email name and password
      affiliate = Affiliate.find_by_name(params[:a])
      if affiliate.nil?
        session[:affiliate_id] = nil
      else
        if affiliate.enabled?
          session[:affiliate_id] = affiliate.id
        else
          session[:affiliate_id] = nil
        end
      end

      @user = User.new
      render_wizard
    when :step_two
      @website = current_user.websites.first
      render_wizard
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
    when :get_key
      # show api key code
      @website = Website.where(:owner_id => current_user.id).last
    end
  end

  def update
    case step
    when :step_three
      @website = Website.new
      @website.url = params['url']
      @website.name = params['name']
      # @website.owner_id = current_user.id
      # session[:website] = {:url => params['url'] }
      unless @website.valid?
        respond_with @website
      else
        head :no_content
      end

    when :step_four
      # @website = Website.where(:owner_id => current_user.id).last
      @website = Website.new
      @website.url = params['url']
      @website.settings(:style).gradient = params['gradient']
      @website.settings(:style).theme = params['theme']
      @website.settings(:online).greeting = params['agent_label']
      @website.settings(:style).position = params['position']
      # if @website.save
      #   redirect_to signup_wizard_path('step_five')
      # end
      if @website.save
        #head :no_contenth
        respond_with @website
      else
        head :no_content
        respond_with @website
      end
    end
  end

  private

  def check_restrictions
    case step
    when :step_one
      if user_signed_in?
        redirect_to root_path()
      end
    when :step_two, :step_three, :step_four, :step_five
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

