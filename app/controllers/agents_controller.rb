class AgentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_user_has_website?
  respond_to :json

  def index
    @agents = current_user.agents
  end

  def create
    params[:website].each_with_index do |website, index|
      # user.push {
      #   website[0]
      puts website[1]["admin"]
      puts website[1]["website"]
    end
    @user = User.create_or_invite_agents(params[:user], params[:agent])
    if @user.errors.any?
      respond_with @user
    end
  end

  def update
    @user = User.update_roles_and_websites(params[:id], params[:account])
    if @user.errors.any?
      render :json => {errors: @user.errors.full_messages}, status: 401
    end
  end

  def destroy
    User.find(params[:id]).destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
