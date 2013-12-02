class QuickResponsesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    @quick_responses = current_user.quick_responses
  end

  def create
    @quick_response = QuickResponse.new(params[:quick_response])
    @quick_response.user = current_user

    unless @quick_response.save
      respond_with @quick_response
    end
  end

  def update
    @qr = QuickResponse.find_by_id params[:id]
    unless @qr.update_attributes(params[:quick_response])
      respond_with @qr
    end
  end

  def destroy
    @qr = QuickResponse.find_by_id params[:id]
    if @qr.destroy
      head :no_content
    end
  end
end
