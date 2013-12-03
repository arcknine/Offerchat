class QuickResponsesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    @quick_responses = current_user.quick_responses
  end

  def create
    if params[:quick_response][:shortcut].blank? or params[:quick_response][:message].blank?
      render json: { errors: {"message" => ["Some fields are blank"]} }, status: 401
    elsif params[:quick_response][:shortcut][0] != "/"
      render json: { errors: {"message" => ["Shortcut invalid format"]} }, status: 401
    else
      @quick_response = QuickResponse.new(params[:quick_response])
      @quick_response.user = current_user

      unless @quick_response.save
        respond_with @quick_response
      end
    end
  end

  def update
    if params[:quick_response][:shortcut].blank? or params[:quick_response][:message].blank?
      render json: { errors: {"message" => ["Some fields are blank"]} }, status: 401
    elsif params[:quick_response][:shortcut][0] != "/"
      render json: { errors: {"message" => ["Shortcut invalid format"]} }, status: 401
    else
      @qr = QuickResponse.find_by_id params[:id]
      unless @qr.update_attributes(params[:quick_response])
        respond_with @qr
      end
    end
  end

  def destroy
    @qr = QuickResponse.find_by_id params[:id]
    if @qr.destroy
      head :no_content
    end
  end
end
