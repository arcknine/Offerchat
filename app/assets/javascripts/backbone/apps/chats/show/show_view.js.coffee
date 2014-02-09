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
      "click a.show-responses" : "show:quick_responses"
      "click a.show-notes"     : "show:notes"

    serializeData: ->
      info: @options.model.get("info")

  class Show.Chat extends App.Views.ItemView
    template:  "chats/show/chat"

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

  class Show.TicketModalDesk extends App.Views.Layout
    template: "chats/show/desk_ticket_modal"
    className: "form form-inline"

    form:
      buttons:
        primary: false
        nosubmit: "Create Ticket"
        cancel:  false
      title: "Create Ticket to Desk"

    events:
      "click div.btn-selector"  : "dropDownButton"
      "click li.option"         : "selectOption"
      "click a.pill"            : "selectPill"

    dropDownButton: (e) ->
      App.execute "drop:button", e

    selectOption: (e) ->
      App.execute "select:option", e

    selectPill: (e) ->
      App.execute "select:pill", e

  class Show.TicketModalZendesk extends App.Views.Layout
    template: "chats/show/zendesk_ticket_modal"
    className: "form form-inline"

    form:
      buttons:
        primary: false
        nosubmit: "Create Ticket"
        cancel:  false
      title: "Create Ticket to Zendesk"

    events:
      "click li.option"         : "selectOption"
      "click div.btn-selector"  : "dropDownButton"
      "click a.pill"            : "selectPill"

    selectPill: (e) ->
      App.execute "select:pill", e

    dropDownButton: (e) ->
      App.execute "drop:button", e

    selectOption: (e) ->
      App.execute "select:option", e

  class Show.ModalQuickResponses extends App.Views.Layout
    template: "chats/show/quick_responses"
    className: "modal-viewer"
    regions:
      qrRegion: "#quick-responses-list"
    triggers:
      "click a.new-response" : "new:response"
      "click a.new-response-cancel" : "cancel:new:response"
      "click .new-response-create"  : "create:new:response"
    form:
      title: "Quick Responses"
      footer: false
      buttons:
        nosubmit: false
        primary: false
        cancel: false

  class Show.ModalVisitorNotesFree extends App.Views.Layout
    template: "chats/show/visitor_notes_free"
    className: "notes-locked-feature"

    events:
      "click a.upgrade-btn" : "upgradeClicked"

    upgradeClicked: ->
      App.navigate Routes.plans_path(), trigger: true

    form:
      title: "Notes for this visitor"
      footer: false
      buttons:
        nosubmit: false
        primary: false
        cancel: false

  class Show.ModalVisitorNotes extends App.Views.Layout
    template: "chats/show/visitor_notes"
    # className: "modal-viewer"
    regions:
      notesRegion: "#visitor-notes-list"
      newNotesRegion: "#new-visitor-notes-form"
    triggers:
      "click a.edit-visitor-info-btn"   : "edit:visitor:info"
      "click button.save-visitor-info" : "save:visitor:info"

    form:
      title: "Notes for this visitor"
      footer: false
      buttons:
        nosubmit: false
        primary: false
        cancel: false

  class Show.ModalVisitorNotesForm extends App.Views.ItemView
    template: "chats/show/visitor_notes_form"
    className: "block"

    events:
      "keyup textarea.visitor-note"   : "saveVisitorNote"

    saveVisitorNote: (ev) ->
      note = $(ev.currentTarget).val()
      if ev.keyCode is 13 and note isnt ""
        @trigger "save:visitor:note", ev, @model

  class Show.VisitorNote extends App.Views.ItemView
    template:  "chats/show/visitor_note"
    className: "chat-item group"

    triggers:
      "click a.delete-note" : "click:delete:note"

  class Show.VisitorNoteConfirm extends App.Views.ItemView
    template: "chats/show/visitor_notes_confirm"
    className: "modal-backdrop"

    triggers:
      "click button.confirm-delete"  : "click:confirm:delete"
      "click button.cancel-delete"  : "click:cancel:delete"
      "click a.close" : "click:cancel:delete"

  class Show.VisitorNotes extends App.Views.CompositeView
    template:  "chats/show/visitor_notes_list"
    itemView: Show.VisitorNote
    itemViewContainer: "#visitor-notes-listing"

    collectionEvents:
      "all" : "render"

  class Show.QuickResponse extends App.Views.ItemView
    template:  "chats/show/quick_response"
    tagName: "li"

    triggers:
      "click a" : "qrs:clicked"

    modelEvents:
      "change" : "render"

  class Show.QuickResponses extends App.Views.CompositeView
    template:  "chats/show/quick_responses_list"
    itemView: Show.QuickResponse
    itemViewContainer: "#qr-list"

    collectionEvents:
      "all" : "render"

