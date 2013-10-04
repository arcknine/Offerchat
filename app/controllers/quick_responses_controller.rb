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
end
