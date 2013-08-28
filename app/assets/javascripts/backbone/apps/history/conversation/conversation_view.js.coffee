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

  class Conversations.Filter extends App.Views.Layout
    template: "history/conversation/filter"
    className: "table-row table-head shadow group"
    regions:
      agentsFilterRegion:   "#agents-filter-region"
    triggers:
      "click .agent-row-selector" : "agents:filter:clicked"

  class Conversations.Item extends App.Views.ItemView
    template: "history/conversation/conversation"
    className: "table-row linkable group"
    modelEvents:
      "change" : "render"
    events:
      #"click" : "select:conversation:clicked"
      "click" : "select_conversation"
    select_conversation: (evt)->
      console.log @
      App.execute "open:conversation:modal", @model

    initialize: ->
      m = @model.get("updated_at")
      @model.set momentary: moment(m, '"YYYY-MM-DDTHH:mm:ss Z"').fromNow()
      setInterval ->
        m = @model.get("created")
        @model.set momentary: moment(m, '"YYYY-MM-DDTHH:mm:ss Z"').fromNow()
      , 60000
  
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

  class Conversations.Chats extends App.Views.CompositeView
    template: "history/conversation/chat_messages"
    itemView: Conversations.ChatMessage
