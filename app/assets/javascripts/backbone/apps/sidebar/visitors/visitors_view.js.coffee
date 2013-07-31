@Offerchat.module "SidebarApp.Visitors", (Visitors, App, Backbone, Marionette, $, _) ->

  class Visitors.Layout extends App.Views.Layout
    template: "sidebar/visitors/layout"
    regions:
      agentsRegion:   "#agents-region"
      visitorsRegion: "#visitors-region"

  class Visitors.View extends App.Views.ItemView
    template:  "sidebar/visitors/visitor"
    triggers:
      "click a.chat-item-tab" : "click:visitor:tab"

    modelEvents:
      "change" : "render"

  class Visitors.List extends App.Views.CompositeView
    template: "sidebar/visitors/visitors"
    itemView: Visitors.View
    itemViewContainer: "div.visitors-wrapper"

  class Visitors.Agent extends App.Views.ItemView
    template: "sidebar/visitors/agent"

  class Visitors.Agents extends App.Views.CompositeView
    template: "sidebar/visitors/agents"
    itemView: Visitors.Agent
