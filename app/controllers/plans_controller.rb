class PlansController < ApplicationController
  before_filter :authenticate_user!

  def index
    @plans = Plan.all
  end

  def by_name
    @plan = Plan.find_by_plan_identifier(params[:id])
  end
end
