@Offerchat.module "AgentsApp.Manage", (Manage, App, Backbone, Marionette, $, _) ->

  class Manage.Controller extends App.Controllers.Base

    initialize: ->
      @layout       = @getLayoutView()
      @current_user = App.request "set:current:user", App.request "get:current:user:json"
      @agents       = App.request "agents:only:entities"
      @websites     = App.request "owned:sites:entities"
      online_agents = App.request "get:online:agents"
      plans        = App.request "get:plans"

      App.execute "when:fetched", @websites , =>
        if @websites.length is 0
          console.log "You are doom!!!"

      App.execute "when:fetched", @agents , =>
        @setAgentStatus online_agents, @agents

        @listenTo online_agents, "all", =>
          @setAgentStatus online_agents, @agents

      App.execute "when:fetched", plans, =>
        @plan = plans.findWhere plan_identifier: @current_user.get("plan_identifier")

      @listenTo @layout, "show", =>
        @showAgents()

      @show @layout

    setAgentStatus: (online_agents, agents) ->
      online_agents.each (agent, key) ->
          online_agent = agents.findWhere { jabber_user: agent.get("token") }
          online_agent.set "status", agent.get("status") if online_agent

    showAgents: ->
      agentsView = @getAgentsView()
      plan       = @current_user.get "plan_identifier"

      @listenTo agentsView, "new:agent:clicked", (item) =>
        agent        = App.request "new:agent:entity"
        addAgentView = @getAddAgentLayout agent
        modalSites   = @getModalSites @websites
        modalLayout  = App.request "modal:wrapper", addAgentView
        websites     = []
        self         = @

        @websites.each (site, key) ->
          websites.push
            website_id: site.get("id")
            url:        site.get("url")
            name:       site.get("name")
            role:       0

        App.modalRegion.show modalLayout
        addAgentView.sitesRegion.show modalSites

        @listenTo modalSites, "childview:modal:check:site", (obj, result) =>
          $.each websites, (index, site) ->
            if site.website_id is result.id
              site.role = result.role

        @listenTo modalLayout, "modal:cancel", (item) ->
          modalLayout.close()

        @listenTo modalLayout, "modal:unsubmit", (obj) =>
          agent.set websites: websites
          # check if user what plan is being used
          if ["PRO", "BASIC", "PROTRIAL"].indexOf(plan) isnt -1
            modalLayout.close()
            @addPlanQty agent
          else
            @addAgent agent, modalLayout

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
        agent       = item.model
        agent_sites = agent.get("websites")

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

        @listenTo manageAgentView, "remove:agent:clicked", (item) =>
          if confirm "Are you sure you want to remove this agent?"
            if ["PRO", "BASIC", "PROTRIAL"].indexOf(plan) isnt -1

            else
              agent.destroy()
              @showNotification("Your changes have been saved!")
              modalLayout.close()

        @listenTo modalSites, "childview:modal:check:site", (obj, result) =>
          $.each agent_sites, (index, site) =>
            if site.id is result.id
              site.role = result.role

        @listenTo modalLayout, "modal:cancel", (item) ->
          modalLayout.close()

        @listenTo modalLayout, "modal:unsubmit", (obj) ->
          console.log obj
          modalLayout.close()

      @layout.agentsRegion.show agentsView

    addAgent: (agent, modal) ->
      agent.save agent.attributes,
        success: (model) =>
          @agents.add model
          @showNotification("Invitation sent!")
          modal.close()

    addPlanQty: (agent) ->
      total = @plan.get("price") * @agents.length

      # add to for owner and new agent
      @plan.set
        agents: @agents.length + 2
        total:  (if total is 0 then "Free" else "$" + total.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,'))

      updatePlanView = @getModalUpdatePlan @plan
      modalLayout    = App.request "modal:wrapper", updatePlanView

      App.modalRegion.show modalLayout

      @listenTo modalLayout, "modal:cancel", (item) ->
        modalLayout.close()

      @listenTo modalLayout, "modal:unsubmit", (obj) =>
        if @plan.get("plan_identifier") is "PROTRIAL"
          @addAgent agent, modalLayout
        else
          # dri ang bayad2x

    getModalUpdatePlan: (plan) ->
      new Manage.UpdatePlan
        model: plan

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