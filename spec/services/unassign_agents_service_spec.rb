require 'spec_helper'

describe UnassignAgentsService do
  xit "should retain " do
    @owner   = Fabricate(:personal_user)
    @website = Fabricate(:website, :owner => @owner)
    @agent1  = Fabricate(:user)
    @agent2  = Fabricate(:user)
    @agent3  = Fabricate(:user)

    Fabricate(:agent, :owner => @owner, :user => @agent1, :website => @website)
    Fabricate(:agent, :owner => @owner, :user => @agent2, :website => @website)
    Fabricate(:agent, :owner => @owner, :user => @agent3, :website => @website)

    puts @owner.my_agents.count
    agents = JSON.parse "{ \"0\": [#{@agent1.id}], \"1\": [#{@agent2.id}, true], \"2\": [#{@agent3.id}, false] }"
    list = UnassignAgentsService.new(agents, @owner)
    list.unassign
    puts @owner.my_agents.count
  end
end