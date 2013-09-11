class UpdateRosterWorker
  include Sidekiq::Worker

  def perform(rid, name)
    service = UpdateRosterService.new(rid, name)
    service.update_roster
  end
end
