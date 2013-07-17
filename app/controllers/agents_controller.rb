class AgentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_user_has_website?
  respond_to :json

  def index
    @agents = current_user.agents
  end

  def create
    accounts = []
    params[:website].each_with_index do |website, index|
      accounts.push website[1]
    end
    puts accounts.inspect
    @user = User.create_or_invite_agents(params[:agent], accounts)
    if @user.errors.any?
      respond_with @user
    end
  end

  def update
    accounts = []
    params[:website].each_with_index do |website, index|
      accounts.push website[1]
    end
    puts accounts.inspect
    @user = User.update_roles_and_websites(params[:id], accounts)
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
