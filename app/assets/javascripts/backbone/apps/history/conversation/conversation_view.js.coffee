@Offerchat.module "HistoryApp.Conversations", (Conversations, App, Backbone, Marionette, $, _) ->
  
  class Conversations.Layout extends App.Views.Layout
    template: "history/conversation/layout"
    className: "main-inner"
    regions:
      headerRegion:         "#history-header-region"
      filterRegion:         "#history-filter-region"
      conversationsRegion:  "#history-conversation-region"
  
  class Conversations.Header extends App.Views.CompositeView
    template: "history/conversation/header"

  class Conversations.Filter extends App.Views.CompositeView
    template: "history/conversation/filter"
    className: "table-row table-head shadow group"
  
  class Conversations.Item extends App.Views.CompositeView
    template: "history/conversation/conversation_item"
    className: "table-row linkable group"
  
  class Conversations.GroupItem extends App.Views.CompositeView
    template: "history/conversation/group_item"
    itemView: Conversations.Item
    initialize: ->
      @collection = App.request "new:conversations:entitites", @model.get("conversations")
    appendHtml: (collectionView, itemView)->
      collectionView.$(".table-row-wrapper").append(itemView.el)
    
  class Conversations.Groups extends App.Views.CompositeView
    template: "history/conversation/groups"
    itemView: Conversations.GroupItem
    className: "table-history-viewer-content"
    id: "historyTableViewer"