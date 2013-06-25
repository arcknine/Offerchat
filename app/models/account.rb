class Account < ActiveRecord::Base
  attr_accessible :role, :user

  OWNER = 1
  ADMIN = 2
  AGENT = 3

  belongs_to :user
  belongs_to :website

  after_create :add_rosters_to_agent_or_admin

  def is_owner?
    role == Account::OWNER
  end

  def is_admin?
    role == Account::ADMIN
  end

  def is_agent?
    role == Account::AGENT
  end

  private

  def add_rosters_to_agent_or_admin
    if self.role == Account::ADMIN || self.role == Account::AGENT
      SubscribeRostersWorker.perform_async(id)
    end
  end
end
