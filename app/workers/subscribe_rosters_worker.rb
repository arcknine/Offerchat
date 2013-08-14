class SubscribeRostersWorker
  include Sidekiq::Worker

  def perform(id)
    account = Account.find(id)
    user    = account.user
    website = Website.find(account.website_id)
    rosters = website.rosters
    rosters.each do |r|
      visitor = r.jabber_user
      agent   = user.jabber_user
      name    = visitor.split("_")

      sleep(1)
      OpenfireApi.subcribe_roster(agent, visitor, "#{name[0]}-#{name[2]}", website.url)
      sleep(1)
      OpenfireApi.subcribe_roster(visitor, agent, "#{name[0]}-#{name[2]}", website.url)
    end
  end
end
