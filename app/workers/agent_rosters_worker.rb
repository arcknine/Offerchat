class AgentRostersWorker
  include Sidekiq::Worker

  def perform(id)
    account = Account.find(id)
    account.befriend_agents
    user    = account.user
    website = account.website
    agents  = website.owner_and_agents

    agents.each do |agent|
      sleep(5)
      OpenfireApi.subcribe_roster(agent, user, user.name, "#{website.url}(Agents)")
      sleep(5)
      OpenfireApi.subcribe_roster(user, agent, agent.name, "#{website.url}(Agents)")
    end
  end
end
