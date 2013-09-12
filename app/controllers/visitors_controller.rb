class VisitorsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
    begin
  	  @visitor = Visitor.find params[:id]
      respond_with @visitor
    rescue
      render json: []
    end
  end
end
