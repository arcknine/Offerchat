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
      App.request "init:preloader", "show"
      agents.fetch
        reset: true
        success: ->
          App.request "init:preloader", "hide"
        error: ->
          App.request "init:preloader", "hide"
      agents

  App.reqres.setHandler "agents:entities", ->
    API.getAgents()

  App.reqres.setHandler "new:agent:entity", ->
    API.newAgent()