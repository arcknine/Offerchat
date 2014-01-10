@Offerchat.module "AgentsApp.Manage", (Manage, App, Backbone, Marionette, $, _) ->

  class Manage.Controller extends App.Controllers.Base

    initialize: ->
      @layout       = @getLayoutView()
      @current_user = App.request "set:current:user", App.request "get:current:user:json"
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

      @listenTo agentsView, "new:agent:clicked", (item) =>
        console.log @websites
        agent        = App.request "new:agent:entity"
        addAgentView = @getAddAgentLayout agent
        modalSites   = @getModalSites @websites
        modalLayout  = App.request "modal:wrapper", addAgentView

        App.modalRegion.show modalLayout
        addAgentView.sitesRegion.show modalSites

        @listenTo modalSites, "childview:modal:check:site", (obj, result) =>
          console.log result
          # $.each agent_sites, (index, site) =>
          #   if site.id is result.id
          #     site.role = result.role

        @listenTo modalLayout, "modal:cancel", (item)->
          modalLayout.close()

        @listenTo modalLayout, "modal:unsubmit", (ob)->
          console.log ob
          modalLayout.close()

      @listenTo agentsView, "show:owner:modal", (item) ->
        item.model.set "is_admin", true
        manageAgentView = @getManageAgentLayout item.model
        modalLayout     = App.request "modal:wrapper", manageAgentView

        App.modalRegion.show modalLayout

        @listenTo modalLayout, "modal:cancel", (item)->
          modalLayout.close()

        @listenTo modalLayout, "modal:unsubmit", (ob)->
          modalLayout.close()

      @listenTo agentsView, "childview:agent:selection:clicked", (item) =>
        agent_sites = item.model.get("websites")

        $.each agent_sites, (index, site) =>
          website = @websites.findWhere { id: site.id }
          unless site.role is 0
            website.set "agentChecked", "checked"
          else
            website.set "agentChecked", ""

        manageAgentView = @getManageAgentLayout item.model
        modalSites      = @getModalSites @websites
        modalLayout     = App.request "modal:wrapper", manageAgentView

        App.modalRegion.show modalLayout
        manageAgentView.sitesRegion.show modalSites

        @listenTo modalSites, "childview:modal:check:site", (obj, result) =>
          $.each agent_sites, (index, site) =>
            if site.id is result.id
              site.role = result.role

        @listenTo modalLayout, "modal:cancel", (item)->
          modalLayout.close()

      @layout.agentsRegion.show agentsView

    getModalSites: (website) ->
      new Manage.Sites
        collection: website

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
        model:      @current_user
        collection: @agents