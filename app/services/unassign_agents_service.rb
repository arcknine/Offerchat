class UnassignAgentsService
  def initialize(agents, owner)
    @agents = agents.collect { |k,v| v[0] if v[1] == false || v[1] == nil }.compact
    @owner  = owner
  end

  def unassign
    Account.where(:owner_id => @owner.id, :user_id => @agents).destroy_all
  end
end