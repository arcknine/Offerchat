class AgentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_user_has_website?
  respond_to :json

  def index
    @agents = current_user.agents
    @owner = current_user
  end

  def create
    accounts = []
    
    params[:agent][:websites].each do |account|
      accounts.push(
        is_admin: (account[:role] < 3),
        website_id: account[:id]
      )
    end

    @user = User.create_or_invite_agents(params[:agent], accounts)
    if @user.errors.any?
      respond_with @user
    end
  end

  def update
    accounts = []
    params[:agent][:websites].each do |account|
      accounts.push(
        is_admin: (account[:role] < 3), 
        website_id: account[:id], 
        account_id: account[:account_id]
      )
    end
    puts ">>>>"
    puts params[:agent][:websites].inspect
    @user = User.update_roles_and_websites(params[:id], accounts)
    if @user.errors.any?
      respond_with @user
    end
  end

  def destroy
    Account.find(params[:id]).destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
