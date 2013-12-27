class WidgetCodesController < ApplicationController
  def index
    redirect_to root_url

  end
  def show
    @website = Website.find(params[:id])
  end
end
