@Offerchat.module "AgentsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayoutView()
      @currentUser = App.request("get:current:user:json")
      agents = App.request "agents:manage:entities"
      @websites = App.request "owned:sites:entities"

      online_agents = App.request "get:online:agents"

      App.execute "when:fetched", @websites , =>
        App.execute "when:fetched", agents , =>
          self = @
          agents.each (agent, index) ->

            res = online_agents.findWhere {token: agent.get("jabber_user")}
            agent.set("status", res.get("status")) if res

            if agent.get("id") is self.currentUser.id
              agent.set
                is_admin: true

          @listenTo online_agents, "all", =>
            online_agents.each (agent, idx) ->
              this_agent = agents.findWhere {jabber_user: agent.get("token")}
              this_agent.set("status", agent.get("status")) if this_agent

      @layout.on "show", =>
        @showAgents agents

      App.mainRegion.show @layout

    showSeats: (seats) ->
      seatsView = @getSeatsView seatsView
      @layout.seatsRegion.show seatsView

    showAgents: (agents) ->
      agentsView = @getAgentsView agents
      self = @

      @listenTo agentsView, "new:agent:clicked", (item) ->
        agent = App.request "new:agent:entity"
        addAgentViewLayout = @getNewAgentViewLayout(agent)
        modalAgentView = App.request "modal:wrapper", addAgentViewLayout

        modalAgentView.on "show", =>
          addAgentView = @getNewAgentView(agent)

          sites = App.request "new:site:entities"

          @websites.each (site, index) ->
            sites.add
              role: 0
              url: site.get("url")
              website_id: site.id
              adminchecked: ""
              agentchecked: ""
              is_admin: false
              is_agent: false

          sitesView = @getSitesView(sites)

          @listenTo modalAgentView, "modal:unsubmit", (ob)->
            agent.set
              websites: sites
            agent.save agent.attributes,
              success: (model)->
                agents.add model
                self.showNotification("Invitation sent!")
                modalAgentView.close()
              error: (data, response)->
                if response.status == 422
                  errs = []
                  errors  = $.parseJSON(response.responseText).errors
                  for attribute, messages of errors
                    if attribute isnt "base"
                      errs.push "#{attribute.charAt(0).toUpperCase()}#{attribute.slice(1)} #{message}" for message in messages
                    else
                      errs.push "#{message}" for message in messages
                  self.showNotification _.first(errs), 'warning'
                modalAgentView.close()

          addAgentViewLayout.agentRegion.show addAgentView
          addAgentViewLayout.sitesRegion.show sitesView

        @listenTo modalAgentView, "modal:cancel", (item)->
          modalAgentView.close()

        App.modalRegion.show modalAgentView

      @listenTo agentsView, "childview:agent:selection:clicked", (item)->
        agent = item.model
        showAgentViewLayout = @getShowAgentViewLayout(agent)
        modalAgentView = App.request "modal:wrapper", showAgentViewLayout

        modalAgentView.on "show", =>
          showAgentView = @getShowAgentView(agent)
          showAgentViewLayout.agentRegion.show showAgentView
          sites = App.request "new:site:entities"
          sites.add agent.get("websites")

          @listenTo showAgentView, "remove:agent:clicked", (item) ->
            agent.destroy()
            self.showNotification("Your changes have been saved!")
            modalAgentView.close()

          if agent.get("id") isnt @currentUser.id
            sitesView = @getSitesView(sites)

            @listenTo modalAgentView, "modal:unsubmit", (ob)->
              agent.set
                websites: sites
              agent.save agent.attributes,
                success: ->
                  agents.fetch()
                  self.showNotification("Your changes have been saved!")
                  modalAgentView.close()

            showAgentViewLayout.sitesRegion.show sitesView

          App.commands.setHandler "check:selected:sites", (item) =>
            console.log item

        @listenTo modalAgentView, "modal:cancel", (item)->
          modalAgentView.close()

        App.modalRegion.show modalAgentView

      @layout.agentsRegion.show agentsView

    getLayoutView: ->
      new List.Layout

    getAgentsView: (agents) ->
      new List.Agents
        collection: agents

    getSeatsView: (seats) ->
      new List.Seats seats

    getShowAgentView: (model) ->
      new List.Show
        model: model

    getShowAgentViewLayout: (model, websites)->
      new List.ShowLayout
        model: model
        websites: websites

    getNewAgentViewLayout: (model, websites)->
      new List.NewLayout
        model: model
        websites: websites

    getNewAgentView: (model)->
      agentView = new List.New
        model: model
      @listenTo agentView, "toggle:checkbox", (item) ->
        console.log item
      agentView

    getSitesView: (collection) ->
      new List.Sites
        collection: collection
