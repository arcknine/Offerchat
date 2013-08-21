@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Agent extends App.Entities.Model
    urlRoot: Routes.agents_path()
    defaults:
      email: ""

  class Entities.AgentsCollection extends App.Entities.Collection
    model: Entities.Agent
    url: Routes.agents_path()

  class Entities.OnlineAgent extends App.Entities.Model
    defaults:
      unread:   null
      active:   null
      new_chat: null
      bounce:   null
      info:
        display_name: "Support"
        avatar:       "http://s3.amazonaws.com/offerchat/users/avatars/avatar.jpg"
        name:         ""

  class Entities.OnlineAgentsCollection extends App.Entities.Collection
    model: Entities.OnlineAgent

  API =
    newAgent: ->
      new Entities.Agent

    getAgents: ->
      agents = new Entities.AgentsCollection
      App.request "show:preloader"
      agents.fetch
        reset: true
        success: ->
          App.request "hide:preloader"
        error: ->
          App.request "hide:preloader"
      agents

    onlineAgents: ->
      new Entities.OnlineAgentsCollection

    onlineAgent: ->
      new Entities.OnlineAgent


  App.reqres.setHandler "agents:entities", ->
    API.getAgents()

  App.reqres.setHandler "agents:only:entities", ->
    API.getAgentsOnly()

  App.reqres.setHandler "new:agent:entity", ->
    API.newAgent()

  App.reqres.setHandler "online:agents:entities", ->
    API.onlineAgents()

  App.reqres.setHandler "online:agent:entity", ->
    API.onlineAgent()