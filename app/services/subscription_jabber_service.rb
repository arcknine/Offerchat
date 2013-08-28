class SubscriptionJabberService
  def initialize(id)
    account  = Account.find(id)
    @user    = account.user
    @website = Website.find(account.website_id)
  end

  def subscribe_rosters
    rosters = @website.rosters
    rosters.each do |r|
      visitor = r.jabber_user
      agent   = @user.jabber_user
      name    = visitor.split("_")

      sleep(1)
      OpenfireApi.subcribe_roster(agent, visitor, "#{name[0]}-#{name[2]}", @website.url)

      sleep(1)
      OpenfireApi.subcribe_roster(visitor, agent, "#{name[0]}-#{name[2]}", @website.url)
    end
  end

  def subscribe_agents
    agents = @website.owner_and_agents
    group  = @user.group(@website.owner.id)
    agents.each do |agent|
      if agent.jabber_user != @user.jabber_user
        sleep(1)
        OpenfireApi.subcribe_roster(agent.jabber_user, @user.jabber_user, @user.name, group)

        sleep(1)
        OpenfireApi.subcribe_roster(@user.jabber_user, agent.jabber_user, agent.name, group)
      end
    end
  end
end