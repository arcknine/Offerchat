class VisitorNotesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def create
    visitor = Visitor.find_by_token params[:vtoken]
    @visitor_notes = visitor.notes.new(:message => params[:message],:user_id=>current_user.id)
    unless @visitor_notes.save
      respond_with @visitor_notes
    end
  end

  def destroy
    @visitor_notes = Note.find_by_id(params[:id])
    if @visitor_notes.destroy
      head :no_content
    end
  end

end
