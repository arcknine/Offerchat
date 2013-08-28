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
    group = @user.group(@website.owner.id)

    agents.each do |agent|
      if agent.jabber_user != @user.jabber_user
        if group.blank?
          sleep(1)
          OpenfireApi.unsubcribe_roster(agent.jabber_user, @user.jabber_user)

          sleep(1)
          OpenfireApi.unsubcribe_roster(@user.jabber_user, agent.jabber_user)
        else
          sleep(1)
          OpenfireApi.update_roster(agent.jabber_user, @user.jabber_user, @user.name, group)

          sleep(1)
          OpenfireApi.update_roster(@user.jabber_user, agent.jabber_user, agent.name, group)
        end
      end
    end
  end
end