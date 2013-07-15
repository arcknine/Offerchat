@Offerchat.module "AgentsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayoutView()
      @currentUser = App.request("get:current:user:json")
      agents = App.request "agents:entities"
      @websites = App.request "site:entities"
      @sites = App.request "new:site:entities"

      App.execute "when:fetched", @websites , =>
        App.execute "when:fetched", agents , =>
          self = @
          agents.each (agent, index) ->
            _.each agent.get("websites"), (owned_site) ->
              website = self.websites.get(owned_site.website_id)
              owned_site["url"] = website.get('url')
              owned_site["adminchecked"] = if owned_site["role"] isnt 3 then "adminchecked"
              owned_site["agentchecked"] = if website isnt null then "agentchecked"

      
      @layout.on "show", =>
        @showAgents agents

      App.mainRegion.show @layout

    showSeats: (seats) ->
      seatsView = @getSeatsView seatsView
      @layout.seatsRegion.show seatsView

    showAgents: (agents) ->
      agentsView = @getAgentsView agents

      agent = App.request "new:agent:entity"
      
      @listenTo agentsView, "new:agent:clicked", (item) ->
        addAgentViewLayout = @getNewAgentViewLayout(agent, @sites)
        modalAgentView = App.request "modal:wrapper", addAgentViewLayout
        
        modalAgentView.on "show", =>
          addAgentView = @getNewAgentView(agent)
          sitesView = @getSitesView(@sites)
          @listenTo sitesView, "childview:account:role:agent:checked", (site)->
            console.log site

          addAgentViewLayout.agentRegion.show addAgentView 
          addAgentViewLayout.sitesRegion.show sitesView  
          
        @listenTo modalAgentView, "modal:cancel", (item)->
          modalAgentView.close()
          
        App.modalRegion.show modalAgentView
      
      @listenTo agentsView, "childview:agent:selection:clicked", (item)->
        showAgentViewLayout = @getShowAgentViewLayout(item.model)
        modalAgentView = App.request "modal:wrapper", showAgentViewLayout
        
        modalAgentView.on "show", =>
          showAgentView = @getShowAgentView(item.model)
          showAgentViewLayout.agentRegion.show showAgentView
          sites = App.request "new:site:entities"

          sites.add item.model.get("websites")

          if item.model.get("id") isnt @currentUser.id
            sitesView = @getSitesView(sites)
          
            @listenTo sitesView, "childview:account:role:admin:checked", (site)->
              site.model.set
                role: 2
              item.model.set
                websites: sites
                
            @listenTo sitesView, "childview:account:role:admin:unchecked", (site)->
              site.model.set
                role: 3
              item.model.set
                websites: sites

            @listenTo sitesView, "childview:account:role:agent:checked", (site)->
              site.model.set
                role: 3
              item.model.set
                websites: sites
              
            @listenTo sitesView, "childview:account:role:agent:unchecked", (site)->
              site.model.set
                role: 0
              item.model.set
                websites: sites
            
            @listenTo modalAgentView, "modal:unsubmit", (ob)->
              item.model.save()
              
            showAgentViewLayout.sitesRegion.show sitesView

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

    getShowAgentView: (model, websites) ->
      new List.Show
        model: model
        websites: websites

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
