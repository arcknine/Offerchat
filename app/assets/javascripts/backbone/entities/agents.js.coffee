@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Agent extends App.Entities.Model
    urlRoot: Routes.agents_path()
    defaults:
      email: ""

  class Entities.AgentsCollection extends App.Entities.Collection
    model: Entities.Agent
    url: Routes.agents_path()

  API =
    newAgent: ->
      new Entities.Agent
      
    getAgents: ->
      agents = new Entities.AgentsCollection
      agents.fetch
        reset: true
      agents

  App.reqres.setHandler "agents:entities", ->
    API.getAgents()

  App.reqres.setHandler "new:agent:entity", ->
    API.newAgent()