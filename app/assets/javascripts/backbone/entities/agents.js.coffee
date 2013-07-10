@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Agents extends App.Entities.Model
    urlRoot: Routes.agents_path()

  class Entities.AgentsCollection extends App.Entities.Collection
    model: Entities.Agents
    url: Routes.agents_path()

  API =
    getAgents: ->
      agents = new Entities.AgentsCollection
      agents.fetch
        reset: true
      agents

  App.reqres.setHandler "agents:entities", ->
    API.getAgents()