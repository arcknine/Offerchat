@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Agent extends App.Entities.Model
    urlRoot: Routes.agents_path()
    defaults:
      display_name: ""
      email: ""
      status: null

  class Entities.AgentsCollection extends App.Entities.Collection
    model: Entities.Agent
    url: Routes.agents_path()

  class Entities.OnlineAgent extends App.Entities.Model
    defaults:
      status:   'online'
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

  class Entities.AgentsOnlyCollection extends App.Entities.Collection
    model: Entities.Agent
    url: Routes.only_agents_path()

  class Entities.ManageAgentsCollection extends App.Entities.Collection
    model: Entities.Agent
    url:   Routes.manage_agents_agents_path()

  API =
    newAgent: ->
      new Entities.Agent

    getAgents: (hide_loader) ->
      agents = new Entities.AgentsCollection
      App.request "show:preloader"
      agents.fetch
        reset: true
        success: ->
          App.request "hide:preloader" if hide_loader
        error: ->
          App.request "hide:preloader"
      agents

    onlineAgents: ->
      new Entities.OnlineAgentsCollection

    onlineAgent: ->
      new Entities.OnlineAgent

    getAgentsOnly: ->
      agents = new Entities.AgentsOnlyCollection
      App.request "show:preloader"
      agents.fetch
        reset: true
        success: ->
          App.request "hide:preloader"
        error: ->
          App.request "hide:preloader"
      agents

    manageAgents: (hide_loader) ->
      agents = new Entities.ManageAgentsCollection
      App.request "show:preloader"
      agents.fetch
        reset: true
        success: ->
          App.request "hide:preloader"
        error: ->
          App.request "hide:preloader"
      agents

  App.reqres.setHandler "agents:entities", (hide_loader = true) ->
    API.getAgents hide_loader

  App.reqres.setHandler "agents:only:entities", ->
    API.getAgentsOnly()

  App.reqres.setHandler "agents:manage:entities", (hide_loader = true) ->
    API.manageAgents hide_loader

  App.reqres.setHandler "new:agent:entity", ->
    API.newAgent()

  App.reqres.setHandler "online:agents:entities", ->
    API.onlineAgents()

  App.reqres.setHandler "online:agent:entity", ->
    API.onlineAgent()