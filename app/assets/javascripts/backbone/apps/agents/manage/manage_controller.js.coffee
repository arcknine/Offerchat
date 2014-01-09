@Offerchat.module "AgentsApp.Manage", (Manage, App, Backbone, Marionette, $, _) ->

  class Manage.Controller extends App.Controllers.Base

    initialize: ->
      @layout       = @getLayoutView()
      @currentUser  = App.request "set:current:user", App.request "get:current:user:json"
      @agents       = App.request "agents:only:entities"
      @websites     = App.request "owned:sites:entities"
      online_agents = App.request "get:online:agents"

      App.execute "when:fetched", @websites , =>
        if @websites.length is 0
          console.log "You are doom!!!"

      App.execute "when:fetched", @agents , =>
        @setAgentStatus online_agents, @agents

        @listenTo online_agents, "all", =>
          @setAgentStatus online_agents, @agents

      @listenTo @layout, "show", =>
        @showAgents()

      @show @layout

    setAgentStatus: (online_agents, agents) ->
      online_agents.each (agent, key) ->
          online_agent = agents.findWhere { jabber_user: agent.get("token") }
          online_agent.set "status", agent.get("status") if online_agent

    showAgents: ->
      agentsView = @getAgentsView()

      @listenTo agentsView, "new:agent:clicked", (item) ->
        agent        = App.request "new:agent:entity"
        addAgentView = @getAddAgentLayout agent
        modalSites   = @getModalSites()
        modalLayout  = App.request "modal:wrapper", addAgentView

        App.modalRegion.show modalLayout
        addAgentView.sitesRegion.show modalSites

        @listenTo modalLayout, "modal:cancel", (item)->
          modalLayout.close()

      @listenTo agentsView, "show:owner:modal", (item) ->
        item.model.set "is_admin", true
        manageAgentView = @getManageAgentLayout item.model
        modalLayout     = App.request "modal:wrapper", manageAgentView

        App.modalRegion.show modalLayout

        @listenTo modalLayout, "modal:cancel", (item)->
          modalLayout.close()

      @listenTo agentsView, "childview:agent:selection:clicked", (item) ->
        console.log item.model
        manageAgentView = @getManageAgentLayout item.model
        modalSites   = @getModalSites()
        modalLayout  = App.request "modal:wrapper", manageAgentView

        App.modalRegion.show modalLayout
        manageAgentView.sitesRegion.show modalSites

        @listenTo modalLayout, "modal:cancel", (item)->
          modalLayout.close()

      @layout.agentsRegion.show agentsView

    getModalSites: ->
      new Manage.Sites
        collection: @websites

    getManageAgentLayout: (model) ->
      new Manage.UpdateLayout
        model: model

    getAddAgentLayout: (model) ->
      new Manage.NewLayout
        model: model

    getLayoutView: ->
      new Manage.Layout

    getAgentsView: ->
      new Manage.Agents
        model:      @currentUser
        collection: @agents