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

  def update_info
    @visitor = Visitor.find_by_token params[:token]
    unless @visitor.update_attributes(:name => params[:info][:name], :email => params[:info][:email], :phone => params[:info][:phone])
      respond_with @visitor
    end
  end

  def notes
    visitor = Visitor.find_by_token(params[:id])
    @notes = visitor.notes
    respond_with @notes
  end
end
