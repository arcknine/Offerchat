class PlansController < ApplicationController
  before_filter :authenticate_user!

  def index
    @plans = Plan.all
  end

  def stripe
    event_json = JSON.parse(request.body.read)
    render status: 200, json: @controller.to_json
  rescue
    render nothing: true, status: 500
  end
end
