@Offerchat.module "AgentsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "agents/list/layout"
    regions:
      seatsRegion:  "#seats-region"
      agentsRegion: "#agents-region"

  class List.Agent extends App.Views.ItemView
    template: "agents/list/agent"
    tagName:  "li"

  class List.Agents extends App.Views.CompositeView
    template:          "agents/list/agents"
    className:         "block large group"
    itemView:          List.Agent

  class List.Seats extends App.Views.CompositeView
    template:  "agents/list/seats"
    className: "go-right align-right"
