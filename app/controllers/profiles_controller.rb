class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
    @profile = current_user
  end
  
  def update
    @profile = current_user
    @profile.update_attributes(params[:profile])
  end
end
