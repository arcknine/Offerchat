class GenerateRostersWorker
  include Sidekiq::Worker

  def perform(id)
    website = Website.find(id)
    owner = website.owner

    (1..30).each do |i|
      visitor = website.genrate_visitor_id
      password = (0..16).to_a.map{|a| rand(16).to_s(16)}.join
      roster   = Roster.create(:jabber_user => visitor, :jabber_password => password, :website_id => id)

      sleep(5)
      OpenfireApi.create_user(roster.jabber_user, roster.jabber_password)
      sleep(5)
      OpenfireApi.subcribe_roster(owner.jabber_user, visitor, name, url)
      sleep(5)
      OpenfireApi.subcribe_roster(visitor, owner.jabber_user, name, url)
    end
  end
end
