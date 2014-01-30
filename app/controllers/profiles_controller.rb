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

    if params[:profile][:update_settings]
      @profile.settings(:notifications).update_attributes! params[:profile][:notifications]
    end

    unless @profile.update_attributes params[:profile].except(:id).except(:avatar).except(:trial_days_left).except(:notifications).except(:update_settings)
      respond_with @profile
    end
  end

  def update_avatar
    puts "profiles"
    puts params
    @profile = current_user
    @profile.avatar = params[:avatar]
    unless @profile.update_attribute('avatar', params[:avatar])
      respond_with @profile
    end
  end
end
