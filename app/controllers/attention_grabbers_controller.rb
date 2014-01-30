class AttentionGrabbersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    @grabbers = AttentionGrabber.all
  end

end
