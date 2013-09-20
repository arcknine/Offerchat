@Offerchat.module "HistoryApp.Conversations", (Conversations, App, Backbone, Marionette, $, _) ->

  class Conversations.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayout()
      agents = App.request "agents:entities"

      currentUser = App.request "get:current:user"
      self = @

      @listenTo @layout, "show", =>
        App.request "hide:preloader"

      App.request "show:preloader"
      App.execute "when:fetched", agents, (item)=>
        if agents.length > 1
          all_agent = App.request "new:agent:entity"
          all_agent.set name: "All Agents"
          agents.unshift(all_agent)
        conversations = App.request "get:conversations:entitites", null, agents.pluck("id")

        App.commands.setHandler "conversations:fetch", (aids)=>
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
            headerRegion = @getHeaderRegion(conversations)
            ids = []
            items = []
            @listenTo headerRegion, "remove:conversations:clicked", (item)->
              _.each $(".table-row[data-checked='true']"), (item)->
                ids.push $(item).data("id")

              $.ajax
                url: "#{gon.history_url}/convo/remove"
                data: {ids: ids}
                dataType : "jsonp"
                processData: true
                success: ->
                  conversations.each (item)->
                    if ($.inArray(item.get("_id"), ids) isnt -1)
                      item.trigger "destroy"
                error: ->
                  App.request "hide:preloader"


            @layout.headerRegion.show headerRegion
            @layout.filterRegion.show @getFilterRegion(agents)
            @layout.conversationsRegion.show @getConversationsRegion(convos)
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

        messages.url = "#{gon.history_url}/chats/#{model.get('token')}"
        messages.fetch
          dataType : "jsonp"
          processData: true
          reset: true

        modalViewRegion.bodyRegion.show modalRegionBody

        modalRegionFooter = new Conversations.ChatModalFooter
          model: model

        @listenTo modalRegionFooter, "close:chats:modal", ->
          modalViewRegion.close()

        modalViewRegion.footerRegion.show modalRegionFooter

      @listenTo modalViewRegion, "close:chats:modal", ->
        modalViewRegion.close()

      App.modalRegion.show modalViewRegion
    
    getHeaderRegion: (conversations)->
      new Conversations.Header
        conversations: conversations

    getFilterView: (collection)->
      new Conversations.Filter
        collection: collection

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
        App.request "show:preloader"
        id = []
        if item.model.get("name") is "All Agents"
          collection.each (item)->
            id.push item.get("id")
        else
          id = [item.model.get("id")]
        App.execute "conversations:fetch", id
        $("span.current-selection").html(item.model.get("name"))
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