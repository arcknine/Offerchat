class WebsitesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_user_has_website? , :except => [:create]
  respond_to :json

  def my_sites
    @websites = current_user.websites
  end

  def index
    @websites = current_user.websites
  end

  def new
    @website = current_user.websites.new
  end


  def show
    @website = current_user.websites.find params[:id]
  end

  def create

    @website = current_user.websites.new(params[:website])
    @website.settings(:style).gradient = params['gradient']
    @website.settings(:style).theme = params['theme']
    @website.settings(:online).greeting = params['greeting']
    @website.settings(:style).position = params['position']

    unless @website.save
      respond_with @website

    end
  end

  def update
    @website = Website.find(params[:id])
    # @website.save_settings(params[:settings])

    unless @website.update_attributes(params[:website])
      respond_with @website
    end
  end

  def update_settings
    @website = Website.find(params[:id])

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
