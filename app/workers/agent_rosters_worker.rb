class AgentRostersWorker
  include Sidekiq::Worker

  def perform(id)
    service = SubscriptionJabberService.new(id)
    service.subscribe_agents
  end
end
