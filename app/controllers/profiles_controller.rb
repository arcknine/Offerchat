class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
    @profile = current_user
  end
  
  def update
    @profile = current_user
    unless @profile.update_attributes(params[:profile])
      render :json => {errors: @profile.errors.full_messages}, status: 401
    end
  end
end
