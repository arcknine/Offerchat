@Offerchat.module "HistoryApp.Conversations", (Conversations, App, Backbone, Marionette, $, _) ->
  
  class Conversations.Layout extends App.Views.Layout
    template: "history/conversation/layout"
    className: "main-inner"
    regions:
      headerRegion:         "#history-header-region"
      filterRegion:         "#history-filter-region"
      conversationsRegion:  "#history-conversations-region"
  
  class Conversations.Header extends App.Views.CompositeView
    template: "history/conversation/header"

  class Conversations.Filter extends App.Views.CompositeView
    template: "history/conversation/filter"
    className: "table-row table-head shadow group"
  
  class Conversations.ListItem extends App.Views.ItemView
    template: "history/conversation/item"
    className: "table-row linkable group"
    
  class Conversations.List extends App.Views.CompositeView
    template: "history/conversation/conversations"
    itemView: Conversations.ListItem
    className: "table-history-viewer"