class HomeController < ApplicationController
   before_filter :authenticate_user!

  def index
    @user = current_user
    gon.rabl "app/views/users/show.rabl", as: "current_user"
  end
end
