@Offerchat.module "HistoryApp.Conversations", (Conversations, App, Backbone, Marionette, $, _) ->
  
  class Conversations.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayout()
      agents = App.request "agents:entities"
      currentUser = App.request "get:current:user"
      self = @

      App.request "show:preloader"
      App.execute "when:fetched", agents, (item)=>
        conversations = App.request "get:conversations:entitites", null, agents.pluck("id")

        App.commands.setHandler "conversations:fetch", (aids)=>
          
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

        App.execute "when:fetched", conversations, (item)=>
          @listenTo @layout, "show", =>
            convos = @organizeConversations(conversations)
            @layout.headerRegion.show @getHeaderRegion()
            @layout.filterRegion.show @getFilterRegion(agents)
            @layout.conversationsRegion.show @getConversationsRegion(convos)
            App.request "hide:preloader"
          @show @layout

        App.commands.setHandler "open:conversation:modal", (item)=>
          @getConversationModal(item)
    
    getLayout: ->
      new Conversations.Layout

    getConversationModal: (model)->
      visitor = App.request "get:visitor:info:entity", model.get("vid")
      messages = App.request "messeges:entities"

      visitor.generateGravatarSource()

      modalViewRegion = new Conversations.ChatsModalRegion
        model: model

      App.execute "when:fetched", visitor, (item) =>

        modalRegionHeader = new Conversations.ChatModalHeader
          model: visitor

        modalViewRegion.headerRegion.show modalRegionHeader

        modalRegionBody = new Conversations.Chats
          collection: messages

        messages.url = "http://history.offerchat.loc:9292/chats/#{model.get('token')}"
        messages.fetch
          dataType : "jsonp"
          processData: true
          reset: true

        modalViewRegion.bodyRegion.show modalRegionBody

        modalRegionFooter = new Conversations.ChatModalFooter
          model: model

        modalViewRegion.footerRegion.show modalRegionFooter


      @listenTo modalViewRegion, "close:chats:modal", ->
        modalViewRegion.close()

      App.modalRegion.show modalViewRegion
    
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
        App.execute "conversations:fetch", [item.model.get("id")]
        filters.closeDropDown()

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