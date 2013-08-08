class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
    @profile = current_user
  end

  def update
    @profile = current_user
    if params[:profile][:avatar_remove]
      @profile.avatar = nil
    end
    unless @profile.update_attributes params[:profile].except(:id).except(:avatar)
      respond_with @profile
    end
  end

  def update_avatar
    @profile = current_user
    @profile.avatar = params[:avatar]
    unless @profile.update_attribute('avatar', params[:avatar])
      respond_with @profile
    end
  end
end
