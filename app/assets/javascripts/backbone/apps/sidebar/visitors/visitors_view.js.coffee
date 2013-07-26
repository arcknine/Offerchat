@Offerchat.module "SidebarApp.Visitors", (Visitors, App, Backbone, Marionette, $, _) ->

  class Visitors.View extends App.Views.ItemView
    template:  "sidebar/visitors/visitor"

  class Visitors.List extends App.Views.CompositeView
    template: "sidebar/visitors/visitors"
    itemView: Visitors.View
    itemViewContainer: "div.visitors-wrapper"
