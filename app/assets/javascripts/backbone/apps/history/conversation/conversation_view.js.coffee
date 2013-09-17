@Offerchat.module "HistoryApp.Conversations", (Conversations, App, Backbone, Marionette, $, _) ->
  
  class Conversations.Layout extends App.Views.Layout
    template: "history/conversation/layout"
    className: "main-inner"
    regions:
      headerRegion:         "#history-header-region"
      filterRegion:         "#history-filter-region"
      conversationsRegion:  "#history-conversation-region"
  
  class Conversations.Agent extends App.Views.ItemView
    template: "history/conversation/agent"
    tagName: "li"
    triggers:
      "click":              "agent:filter:selected"
    
  class Conversations.Agents extends App.Views.CollectionView
    template: "history/conversation/agents"
    itemView: Conversations.Agent
    tagName: "ul"

  class Conversations.Header extends App.Views.CompositeView
    template: "history/conversation/header"
    triggers:
      "click .trash-btn"    : "remove:conversations:clicked"

  class Conversations.Filter extends App.Views.Layout
    template: "history/conversation/filter"
    className: "table-row table-head shadow group"
    regions:
      agentsFilterRegion:   "#agents-filter-region"

    triggers:
      "click .agent-row-selector" : "agents:filter:clicked"

    serializeData: ->
      agents_count: @collection.length > 1
      agent: @collection.at(0).get("name")


  class Conversations.Item extends App.Views.ItemView
    template: "history/conversation/conversation"
    className: "table-row linkable group"
    modelEvents:
      "change" : "render"
    events:
      "click"                 : "open_conversation"
      "click label.checkbox"  : "select_conversation"

    select_conversation: (evt)->
      evt.stopPropagation()
      evt.preventDefault()
      checkbox = $(evt.target).closest("label.checkbox")
      if checkbox.hasClass("checked") 
        checkbox.removeClass("checked")
        $(evt.target).closest(".table-row").removeAttr("data-id")
        $(evt.target).closest(".table-row").removeAttr("data-checked")
      else
        checkbox.addClass("checked")
        $(evt.target).closest(".table-row").attr("data-id", @model.get("_id"))
        $(evt.target).closest(".table-row").attr("data-checked", true)

    open_conversation: (evt)->
      console.log evt
      App.execute "open:conversation:modal", @model

    initialize: ->
      m = @model.get("updated_at")
      @model.set momentary: moment(m, '"YYYY-MM-DDTHH:mm:ss Z"').fromNow()
      #model = @model
      # setInterval ->
      #   model.set momentary: moment(m, '"YYYY-MM-DDTHH:mm:ss Z"').fromNow()
      # , 3000
  
  class Conversations.GroupItem extends App.Views.CompositeView
    template: "history/conversation/group_item"
    itemView: Conversations.Item
    modelEvents:
      "change" : "render"
    initialize: ->
      momentary = @model.get("created")
      @model.set momentary: moment(@model.get("created")).format("MMMM DD, YYYY")
      @collection = App.request "new:conversations:entitites", @model.get("conversations")
    appendHtml: (collectionView, itemView)->
      collectionView.$(".table-row-wrapper").append(itemView.el)
    
  class Conversations.EmptyView extends App.Views.ItemView
    template: "history/conversation/empty"
    
  class Conversations.Groups extends App.Views.CollectionView
    template: "history/conversation/groups"
    itemView: Conversations.GroupItem
    emptyView: Conversations.EmptyView
    className: "table-history-viewer-content"
    id: "historyTableViewer"

  class Conversations.ChatsModalRegion extends App.Views.Layout
    template: "history/conversation/chats_modal"
    regions:
      headerRegion:   "#chat-modal-header-region"
      bodyRegion:     "#chat-modal-body-region"
      footerRegion:   "#chat-modal-footer-region"
    triggers:
      "click a.close" : "close:chats:modal"

  class Conversations.ChatModalHeader extends App.Views.ItemView
    template: "history/conversation/chats_modal_header"

  class Conversations.ChatMessage extends App.Views.ItemView
    template: "history/conversation/chat_message"
    modelEvents:
      "change" : "render"
    initialize: ->
      momentary = @model.get("sent")
      @model.set sent: moment(@model.get("sent")).format("hh:mma")

  class Conversations.Chats extends App.Views.CompositeView
    template: "history/conversation/chat_messages"
    itemView: Conversations.ChatMessage

  class Conversations.ChatModalFooter extends App.Views.ItemView
    template: "history/conversation/chat_modal_footer"
    events:
      "click #forwardToEmailBtn"        : "show_forward_email"
      "click #cancelTranscriptFormBtn"  : "hide_forward_email"
      "click .forward-to-email-btn"     : "forward_convo_to_email"
      "click .delete-conversation"      : "delete_convo"
      "click #downloadTranscript"       : "download_transcript"

    download_transcript: (evt)->
      evt.preventDefault()
      window.location.href = "#{gon.history_url}/transcript/agent/#{@model.get('token')}"

    show_forward_email: (evt)->
      @$(".transcript-email-form").removeClass("hide")
      @$(".transcript-actions").addClass("hide")

    hide_forward_email: (evt)->
      @$(".transcript-email-form").addClass("hide")
      @$(".transcript-actions").removeClass("hide")

    forward_convo_to_email: (evt)->
      console.log "Process forwarding to email here"
      console.log @$(".forwarding-recipient").val()

    delete_convo: (evt)->
      console.log "Process deleting of this conversation"
      self = @
      conversations = @collection
      ids = [@model.get("_id")]
      self.trigger "close:chats:modal"
      $.ajax
        url: "#{gon.history_url}/convo/remove"
        data: {ids: ids}
        dataType : "jsonp"
        processData: true
        success: ->
          self.trigger "close:chats:modal"
          self.model.destroy()