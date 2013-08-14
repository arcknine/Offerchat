class AgentRostersWorker
  include Sidekiq::Worker

  def perform(id)
    account = Account.find(id)
    # account.befriend_agents
    user    = account.user
    website = account.website
    agents  = website.owner_and_agents

    agents.each do |agent|
      if agent.jabber_user != user.jabber_user
        sleep(1)
        OpenfireApi.subcribe_roster(agent.jabber_user, user.jabber_user, user.name, "#{website.url} (Agents)")
        sleep(1)
        OpenfireApi.subcribe_roster(user.jabber_user, agent.jabber_user, agent.name, "#{website.url} (Agents)")
      end
    end
  end
end
