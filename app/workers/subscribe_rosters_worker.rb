class SubscribeRostersWorker
  include Sidekiq::Worker

  def perform(id)
    service = SubscriptionJabberService.new(id)
    service.subscribe_rosters
  end
end
