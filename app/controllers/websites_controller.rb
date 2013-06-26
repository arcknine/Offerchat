class WebsitesController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @website = current_user.websites
  end
end
