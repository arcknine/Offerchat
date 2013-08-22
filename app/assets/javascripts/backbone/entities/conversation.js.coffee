@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Conversation extends App.Entities.Model
    
  class Entities.Conversations extends App.Entities.Collection
    model: Entities.Conversation
    url: "http://history.offerchat.loc:9292"
  
  API =
    getConversations: ->
      conversations = new Entities.Conversations
      conversations.fetch
        dataType : "jsonp"
        reset: true
      conversations
  
  App.reqres.setHandler "get:conversations:entitites", ->
    API.getConversations()
  