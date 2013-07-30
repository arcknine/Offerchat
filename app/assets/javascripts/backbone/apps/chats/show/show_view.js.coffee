@Offerchat.module "ChatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "chats/show/layout"
    className: "main-inner"
    regions:
      visitorRegion:  "#visitor-info-region"
      chatsRegion:    "#chats-region"

  class Show.VisitorInfo extends App.Views.ItemView
    template:  "chats/show/visitor"
    className: "block chat-header"
    modelEvents:
      "change" : "render"

  class Show.Chat extends App.Views.ItemView
    template:  "chats/show/chat"
    # className: "block chat-header"

  class Show.ChatsList extends App.Views.CompositeView
    template:  "chats/show/chats"
    className: "chat-pane-container"
    itemView:  Show.Chat
    itemViewContainer: "div#chats-collection"
    events:
      "keyup div.chat-response > textarea" : "isTyping"

    isTyping: (ev) ->
      @trigger "is:typing", ev