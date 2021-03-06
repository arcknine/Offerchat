@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Conversation extends App.Entities.Model

  class Entities.ConversationGroup extends App.Entities.Model
    defaults:
      conversations: []

  class Entities.ConversationGroups extends App.Entities.Collection
    model: Entities.ConversationGroup

  class Entities.Conversations extends App.Entities.Collection
    model: Entities.Conversation
    url: "#{gon.history_url}/convo"

  API =
    getConversations: (conversations, aids = [], wids = [])->
      conversations = new Entities.Conversations if conversations is null
      conversations.fetch
        data: {aids: aids, wids: wids}
        dataType : "jsonp"
        processData: true
      conversations

    newConversations: (collection)->
      new Entities.Conversations collection

    newConversationGroup: (created)->
      new Entities.ConversationGroup
        created: created

    newConversationGroups: ->
      new Entities.ConversationGroups

  App.reqres.setHandler "get:conversations:entitites", (collection, aid, wid)->
    API.getConversations(collection, aid, wid)

  App.reqres.setHandler "new:conversations:entitites", (collection)->
    API.newConversations(collection)

  App.reqres.setHandler "new:converstationgroup:entity", (created)->
    API.newConversationGroup(created)

  App.reqres.setHandler "new:converstationgroups:entities", ->
    API.newConversationGroups()
