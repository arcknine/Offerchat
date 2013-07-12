class WebsitesController < ApplicationController
  before_filter :authenticate_user!
  # before_filter :current_user_has_website?
  respond_to :json

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

    unless @website.save
      respond_with @website
    end
  end

  def update
    @website = Website.find(params[:id])

    website = params[:website]
    if @website.update_attributes(:name => website["name"], :url => website["url"])
      @website
    else
      render :json => {errors: @website.errors.full_messages}, status: 401
    end
  end

  def destroy
    @website = Website.find(params[:id]).destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
