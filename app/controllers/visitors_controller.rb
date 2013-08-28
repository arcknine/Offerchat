class VisitorsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
  	@visitor = Visitor.find params[:id]
  end
end
