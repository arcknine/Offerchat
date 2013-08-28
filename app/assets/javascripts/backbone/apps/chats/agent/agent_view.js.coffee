@Offerchat.module "ChatsApp.Agent", (Agent, App, Backbone, Marionette, $, _) ->

  class Agent.Layout extends App.Views.Layout
    template: "chats/agent/layout"
    className: "main-inner"
    regions:
      agentRegion:  "#agent-info-region"
      chatsRegion:  "#chats-region"

  class Agent.Info extends App.Views.ItemView
    template:  "chats/agent/info"
    className: "block chat-header"
    modelEvents:
      "change" : "render"

  class Agent.Chat extends App.Views.ItemView
    template:  "chats/agent/chat"

    triggers:
      "click .chat-transfer-actions a.success"  : "chat:transfer:accept"
      "click .chat-transfer-actions a.warning"  : "chat:transfer:decline"

  class Agent.Chats extends App.Views.CompositeView
    template:  "chats/agent/chats"
    className: "chat-pane-container"
    itemView:  Agent.Chat
    itemViewContainer: "div#chats-collection"

    collectionEvents:
      "change" : "render"

    modelEvents:
      "change" : "render"

    serializeData: ->
      height: @options.model.toJSON()

    events:
      "keyup div.chat-response > textarea"    : "isTyping"

    isTyping: (ev) ->
      @trigger "agent:is:typing", ev