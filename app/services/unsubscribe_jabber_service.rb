class UnsubscribeJabberService
  def initialize(uid, wid)
    @user    = User.find(uid)
    @website = Website.find(wid)
  end

  def unsubscribe_rosters
    rosters = @website.rosters
    rosters.each do |r|
      sleep(1)
      OpenfireApi.unsubcribe_roster(@user.jabber_user, r.jabber_user)

      sleep(1)
      OpenfireApi.unsubcribe_roster(r.jabber_user, @user.jabber_user)
    end
  end

  def unsubscribe_agents
    agents = @website.owner_and_agents
    agents.each do |agent|
      if agent.jabber_user != @user.jabber_user
        sleep(1)
        OpenfireApi.unsubcribe_roster(agent.jabber_user, @user.jabber_user)

        sleep(1)
        OpenfireApi.unsubcribe_roster(@user.jabber_user, agent.jabber_user)
      end
    end
  end
end