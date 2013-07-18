class AgentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_user_has_website?
  respond_to :json

  def index
    @agents = current_user.agents
  end

  def create
    accounts = []
    
    params[:websites].each do |account|
      accounts.push(
        is_admin: (account[:role] < 3),
        website_id: account[:website_id],
        account_id: account[:id]
      )
    end
    puts accounts.inspect

    #@user = User.create_or_invite_agents(params[:agent], accounts)
    #if @user.errors.any?
    #  respond_with @user
    #end
  end

  def update
    accounts = []
    params[:websites].each do |account|
      accounts.push(
        is_admin: (account[:role] < 3), 
        website_id: account[:website_id], 
        account_id: account[:id]
      )
    end

    @user = User.update_roles_and_websites(params[:id], accounts)
    if @user.errors.any?
      respond_with @user
    end
  end

  def destroy
    User.find(params[:id]).destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
