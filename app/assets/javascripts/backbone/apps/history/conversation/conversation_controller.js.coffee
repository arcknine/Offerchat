@Offerchat.module "HistoryApp.Conversations", (Conversations, App, Backbone, Marionette, $, _) ->
  
  class Conversations.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayout()
      conversations = App.request "get:conversations:entitites"
      
      App.execute "when:fetched", conversations, =>
        @listenTo @layout, "show", =>
          convos = @organizeConverstations(conversations)
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
      new Conversations.List
        collection: collection
    
    organizeConverstations: (collection)->
      convos = collection
      console.log convos
      convos