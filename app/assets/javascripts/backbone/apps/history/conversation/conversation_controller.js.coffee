@Offerchat.module "HistoryApp.Conversations", (Conversations, App, Backbone, Marionette, $, _) ->
  
  class Conversations.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayout()
      conversations = App.request "get:conversations:entitites"
      
      App.execute "when:fetched", conversations, =>
        @listenTo @layout, "show", =>
          convos = @organizeConversations(conversations)
          @layout.headerRegion.show @getHeaderRegion()
          @layout.filterRegion.show @getFilterRegion()
          @layout.conversationsRegion.show @getConversationsRegion(convos)
        @show @layout
    
    getLayout: ->
      new Conversations.Layout
    
    getHeaderRegion: ->
      new Conversations.Header
    
    getFilterRegion: ->
      new Conversations.Filter
    
    getConversationsRegion: (collection)->
      console.log collection
      new Conversations.Groups
        collection: collection
    
    organizeConversations: (collection)->
      timestamps = _.uniq collection.pluck("created")
      convos = App.request "new:converstationgroups:entities"
      _.each timestamps, (item, i)->
        convos.add conversations: collection.where({created: item}), created: item, id: i
      console.log convos
      convos