class TriggersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    if params[:website_id]
      @triggers = Trigger.where(:website_id => params[:website_id])
    else
      head :unauthorized
    end
  end

  def new
    website = Website.find_by_id(params[:website_id])
    @trigger = website.triggers.new
  end

  def show
    @trigger = Trigger.find_by_id(params[:id])
  end

  def create
    website = Website.find_by_id(params[:website_id])
    params[:trigger][:rule_type] = params[:rule_type]
    params[:trigger][:params] = {"time" => params[:time],"url" => params[:url]}
    params[:trigger][:message] = params[:message]

    if params[:time].to_i < 5  && (params[:trigger][:rule_type]=="1" or params[:trigger][:rule_type]=="2")
      render json: { errors: {"time" => "should be at least 5 seconds"} }, status: 401
    else
      @trigger = website.triggers.new(params[:trigger])

      unless @trigger.save
        respond_with @trigger
      end
    end
  end

  def update
    @trigger = Trigger.find_by_id(params[:id])
    params[:trigger][:params] = {"time" => params[:time],"url" => params[:url]}

    if params[:time].to_i < 5 && (params[:trigger][:rule_type]=="1" or params[:trigger][:rule_type]=="2")
      render json: { errors: {"time" => "should be at least 5 seconds"} }, status: 401
    else
      unless @trigger.update_attributes(params[:trigger].except(:website_id))
        respond_with @trigger
      end
    end
  end

  def destroy
    @trigger = Trigger.find_by_id(params[:id])
    if @trigger.destroy
      head :no_content
    end
  end
end