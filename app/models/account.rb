class Account < ActiveRecord::Base
  attr_accessible :role, :user, :owner

  OWNER = 1
  ADMIN = 2
  AGENT = 3

  belongs_to :user
  belongs_to :website

  belongs_to :owner, :foreign_key => :owner_id, :class_name => "User"

  # after_create  :add_rosters_to_agent_or_admin, :if => lambda { |account| account.try(:role) == AGENT || account.try(:role) == ADMIN }
  after_destroy :unsubscribe_rosters_to_agent_or_admin

  def role_in_word
    if role == Account::OWNER
      "Owner"
    elsif role == Account::ADMIN
      "Admin"
    elsif role == Account::AGENT
      "Agent"
    end
  end

  def is_owner?
    role == Account::OWNER
  end

  def is_admin?
    role == Account::ADMIN
  end

  def is_agent?
    role == Account::AGENT
  end

  def pending?
    created_at == updated_at && role != Account::OWNER
  end

  def add_rosters
    if role == AGENT || role == ADMIN
      # Add the visitor rosters
      SubscribeRostersWorker.perform_async(id)
      # Add the agent rosters
      AgentRostersWorker.perform_async(id)
    end
  end

  private

  def add_rosters_to_agent_or_admin
    # Add the visitor rosters
    SubscribeRostersWorker.perform_async(id)
    # Add the agent rosters
    AgentRostersWorker.perform_async(id)
  end

  def unsubscribe_rosters_to_agent_or_admin
    UnsubscribeRostersWorker.perform_async(user_id, website_id)
    UnsubscribeAgentsWorker.perform_async(user_id, website_id)
  end
end
