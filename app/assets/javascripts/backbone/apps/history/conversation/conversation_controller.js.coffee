@Offerchat.module "HistoryApp.Conversations", (Conversations, App, Backbone, Marionette, $, _) ->
  
  class Conversations.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayout()
      agents = App.request "agents:entities"
      currentUser = App.request "get:current:user"
      conversations = App.request "get:conversations:entitites", null, [currentUser.id]

      App.commands.setHandler "converstations:fetch", (aids)=>
        self = @
        App.request "show:preloader"
        conversations.fetch
          data: {aids: aids}
          dataType : "jsonp"
          processData: true
          reset: true
          success: ->
            convos = self.organizeConversations(conversations)
            self.layout.conversationsRegion.show self.getConversationsRegion(convos)
            App.request "hide:preloader"

      App.request "show:preloader"
      App.execute "when:fetched", conversations, (item)=>
        @listenTo @layout, "show", =>
          convos = @organizeConversations(conversations)
          @layout.headerRegion.show @getHeaderRegion()
          App.execute "when:fetched", agents, (item)=>
            @layout.filterRegion.show @getFilterRegion(agents)
          @layout.conversationsRegion.show @getConversationsRegion(convos)
          App.request "hide:preloader"
        @show @layout
    
    getLayout: ->
      new Conversations.Layout
    
    getHeaderRegion: ->
      new Conversations.Header
    
    getFilterView: ->
      new Conversations.Filter
        
    getFilterRegion: (collection)->
      filterView = @getFilterView(collection)
      @listenTo filterView, "agents:filter:clicked", (child)->
        params =
          element: child
          openClass: "btn-selector"
          activeClass: "agent-row-selector"
        filterView.toggleDropDown(params)
      
      @listenTo filterView, "show", =>
        filterView.agentsFilterRegion.show @getAgentFilters(collection)
      filterView
    
    getAgentFilters: (collection)->
      filters = new Conversations.Agents
        collection: collection
      @listenTo filters, "childview:agent:filter:selected", (item)->
        App.execute "converstations:fetch", [item.model.get("id")]

      filters
    
    getConversationsRegion: (collection)->
      new Conversations.Groups
        collection: collection
    
    organizeConversations: (collection)->
      timestamps = _.uniq collection.pluck("created")
      convos = App.request "new:converstationgroups:entities"
      _.each timestamps, (item, i)->
        convos.add conversations: collection.where({created: item}), created: item, id: i
      convos