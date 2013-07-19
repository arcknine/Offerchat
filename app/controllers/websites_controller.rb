class WebsitesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_user_has_website? , :except => [:create]
  respond_to :json

  def index
    @websites = current_user.all_sites
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
    @website = current_user.websites.find(params[:id])
    # @website.save_settings(params[:settings])

    unless @website.update_attributes(params[:website])
      respond_with @website
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
end
