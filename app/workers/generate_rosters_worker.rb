class GenerateRostersWorker
  include Sidekiq::Worker

  def perform(id, url, role)
    website = Website.find(id)
    agent = website.owner.jabber_user

    uniqueid = (0..9).to_a.shuffle[0,6].join
    visitor  = "visitor_#{id}_#{uniqueid}"

    if role == 1
      password = (0..16).to_a.map{|a| rand(16).to_s(16)}.join
      roster   = Roster.new(:jabber_user => visitor, :jabber_password => password, :website_id => id)
      roster.save

      OpenfireApi.create_user(roster.jabber_user, roster.jabber_password)
    end

    group = url
    name  = visitor.split("_")
    name  = "#{name[0]}-#{name[2]}"

    # subscribe agent to visitor
    OpenfireApi.subcribe_roster(agent, visitor, name, group)

    # subscribe visitor to agent
    OpenfireApi.subcribe_roster(visitor, agent, name, group)
  end
end
