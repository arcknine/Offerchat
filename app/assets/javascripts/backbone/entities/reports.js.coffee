@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.AssignedAgent extends App.Entities.Model

  class Entities.AssignedAgents extends App.Entities.Collection
    model: Entities.AssignedAgent

  class Entities.CurrentWebsite extends App.Entities.Model
    defaults:
      all:  true
      name: "All Websites"

  API =
    assignedAgents: ->
      new Entities.AssignedAgents

    currentWebsite: ->
      new Entities.CurrentWebsite

  App.reqres.setHandler "reports:assigned:agents", ->
    API.assignedAgents()

  App.reqres.setHandler "reports:current:website", ->
    API.currentWebsite()