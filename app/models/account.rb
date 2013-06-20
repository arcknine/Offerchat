class Account < ActiveRecord::Base
  attr_accessible :role

  OWNER = 1
  ADMIN = 2
  AGENT = 3

  belongs_to :user
  belongs_to :website

  after_create :add_rosters_to_agent_or_admin

  private

  def add_rosters_to_agent_or_admin
    if self.role == Account::ADMIN || self.role == Account::AGENT
      SubscribeRostersWorker.perform_async(id)
    end
  end
end
