@Offerchat.module "ChatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "chats/show/layout"
    className: "main-inner"
    regions:
      visitorRegion:  "#visitor-info-region"
      chatsRegion:    "#chats-region"

    serializeData: ->
      is_chatting: @options.is_chatting
      agent_name: @options.agent_name

  class Show.VisitorInfo extends App.Views.ItemView
    template:  "chats/show/visitor"
    className: "block chat-header"
    modelEvents:
      "change" : "render"
      
    triggers:
      "click a.btn.show-responses" : "show:quick_responses"

  class Show.Chat extends App.Views.ItemView
    template:  "chats/show/chat"
    # className: "block chat-header"

  class Show.ChatsList extends App.Views.CompositeView
    template:  "chats/show/chats"
    className: "chat-pane-container"
    itemView:  Show.Chat
    itemViewContainer: "div#chats-collection"
    events:
      "keyup div.chat-response > textarea"    : "isTyping"
      "click div.dropdown-options > ul > li"  : "optionSelected"

    collectionEvents:
      "change" : "render"

    modelEvents:
      "change" : "render"

    triggers:
      "click a.end_chat"        : "end:chat"
      "click div.btn-selector"  : "actions:menu:clicked"

    onRender: ->
      $("textarea").focus()

    serializeData: ->
      height: @options.model.toJSON()

    isTyping: (ev) ->
      @trigger "is:typing", ev

    optionSelected: (e) ->
      @trigger "menu:option:selected", e

  class Show.TransferChatLayout extends App.Views.Layout
    template: "chats/show/transfer_chat_layout"
    className: "form form-inline"

    regions:
      agentsListRegion: "#agents-list"

    form:
      buttons:
        primary: false
        nosubmit: "Transfer Chat"
        cancel:  false
      title: "Transfer this chat"

    triggers:
      "click div.btn-selector" : "choose:agent:clicked"

    serializeData: ->
      firstAgent: @options.firstAgent.toJSON()

  class Show.TransferChatAgent extends App.Views.ItemView
    template: "chats/show/transfer_chat_agent"
    tagName: "li"

    triggers:
      "click a" : "select:transfer:agent"

  class Show.TransferChatAgents extends App.Views.CompositeView
    template: "chats/show/transfer_chat_agents"
    itemView: Show.TransferChatAgent
    tagName: "ul"


  class Show.ChatTranscript extends App.Views.ItemView
    template: "chats/show/transcript_chat"

  class Show.TransciptModal extends App.Views.CompositeView
    template: "chats/show/transcript_modal"
    itemView:  Show.ChatTranscript
    itemViewContainer: "div#transcript-collection"
    className: "form"
    form:
      buttons:
        primary: " Send Transcript "
        nosubmit: false
        cancel:  false
      title: "Export Transcript"