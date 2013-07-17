class SettingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
  end
end
