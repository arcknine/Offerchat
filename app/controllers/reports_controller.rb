class ReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_user_has_website?

  def index
  end

  def ratings
    @ratings = Rating.filter(params)
  end
end
