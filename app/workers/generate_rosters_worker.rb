class GenerateRostersWorker
  include Sidekiq::Worker

  def perform(id)
    website = Website.find(id)
    owner = website.owner

    (1..30).each do |i|
      visitor  = website.generate_visitor_id
      password = (0..16).to_a.map{|a| rand(16).to_s(16)}.join
      roster   = Roster.create(:jabber_user => visitor, :jabber_password => password, :website_id => id)
      name     = visitor.split("_")

      sleep(1)
      OpenfireApi.create_user(roster.jabber_user, roster.jabber_password)
      sleep(1)
      OpenfireApi.subcribe_roster(owner.jabber_user, visitor, "#{name[0]}-#{name[2]}", website.url)
      sleep(1)
      OpenfireApi.subcribe_roster(visitor, owner.jabber_user, "#{name[0]}-#{name[2]}", website.url)
    end
  end
end
