class UnsubscribeRostersWorker
  include Sidekiq::Worker

  def perform(uid, wid)
    service = UnsubscribeJabberService.new(uid, wid)
    service.unsubscribe_rosters
  end
end
