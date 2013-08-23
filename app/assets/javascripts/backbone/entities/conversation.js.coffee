@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Conversation extends App.Entities.Model
  
  class Entities.ConversationGroup extends App.Entities.Model
    defaults:
      conversations: []
    
  class Entities.ConversationGroups extends App.Entities.Collection
    model: Entities.ConversationGroup
    
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
    
    newConversations: (collection)->
      new Entities.Conversations collection
    
    newConversationGroup: (created)->
      new Entities.ConversationGroup
        created: created
    
    newConversationGroups: ->
      new Entities.ConversationGroups
  
  App.reqres.setHandler "get:conversations:entitites", ->
    API.getConversations()

  App.reqres.setHandler "new:conversations:entitites", (collection)->
    API.newConversations(collection)
  
  App.reqres.setHandler "new:converstationgroup:entity", (created)->
    API.newConversationGroup(created)

  App.reqres.setHandler "new:converstationgroups:entities", ->
    API.newConversationGroups()