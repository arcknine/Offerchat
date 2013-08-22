class WebsitesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_user_has_website? , :except => [:create]
  respond_to :json

  def index
    # @websites = current_user.all_sites
    # @websites = @all_sites
  end

  def owned
    @websites = current_user.websites
  end

  def managed
    @websites = current_user.admin_sites
  end

  def new
    @website = current_user.websites.new
  end

  def triggers
    @website = current_user.websites.find params[:id]
    @triggers = @website.triggers
  end

  def show
    @website = current_user.websites.find params[:id]
  end

  def webmaster_code
    if params[:email].present? && params[:api_key].present? && validate_email(params[:email].to_s)
      UserMailer.delay.send_to_webmaster( params[:email].to_s, current_user.name, params[:api_key].to_s )
      render json: { success: {"success" => ["email sent!"]} }, status: 200
    else
      render json: { errors: {"email" => ["should be valid and not blank"]} }, status: 401
    end

  end

  def create

    @website = current_user.websites.new(params[:website])
    @website.settings(:style).gradient = params['gradient']
    @website.settings(:style).theme = params['color']
    @website.settings(:style).rounded = true
    @website.settings(:online).agent_label = params['greeting']
    @website.settings(:style).position = params['position']

    unless @website.save
      respond_with @website
    end
  end

  def update
    if params[:website][:name].blank?
      render json: { errors: {"name" => ["should not be blank"]} }, status: 401
    elsif params[:website][:url].blank?
      render json: { errors: {"url" => ["should not be blank"]} }, status: 401
    else
      @website = current_user.websites.find(params[:id])

      unless @website.update_attributes(params[:website])
        respond_with @website
      end
    end
  end

  def update_settings
    @website = current_user.find_managed_sites(params[:id])

    unless @website.save_settings(params[:settings])
      respond_with @website
    end
  end

  def destroy
    @website = Website.find(params[:id])
    if @website.destroy
      head :no_content
    end
  end

  private
  def validate_email(email)
    email_regex = %r{
      ^ # Start of string
      [0-9a-z] # First character
      [0-9a-z.+]+ # Middle characters
      [0-9a-z] # Last character
      @ # Separating @ character
      [0-9a-z] # Domain name begin
      [0-9a-z.-]+ # Domain name middle
      [0-9a-z] # Domain name end
      $ # End of string
    }xi # Case insensitive

    if (email =~ email_regex) == 0
      return true
    else
      return false
    end
  end



end
