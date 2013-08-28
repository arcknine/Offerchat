class AgentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_user_has_website?
  respond_to :json

  def index
    @agents = current_user.agents
    @owner = current_user
  end

  def only
    @owner = current_user
    @agents = current_user.my_agents
  end

  def create
    @owner = current_user
    accounts = []
    params[:websites].each do |account|
      accounts.push(
        is_admin: (account[:role] == 2),
        website_id: account[:website_id],
        role: account[:role]
      )
    end
    @user = User.create_or_invite_agents(current_user, params[:agent], accounts)
    if @user.errors.any?
      respond_with @user
    end
  rescue Exceptions::AgentLimitReachedError
    user = User.new
    user.errors[:base] << "Agent limit reached. Upgrade your plan to add more agents"

    respond_with user
  end

  def update
    @owner = current_user
    accounts = []

    params[:websites].each do |account|
      accounts.push(
        is_admin: (account[:role] == 2),
        website_id: account[:id],
        account_id: account[:account_id],
        role: account[:role]
      )
    end
    @user = User.update_roles_and_websites(params[:id], current_user, accounts)
    if @user.errors.any?
      respond_with @user
    end
  end

  def destroy
    current_user.websites.each do |website|
      Account.where(user_id: params[:id], website_id: website.id).destroy_all
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
