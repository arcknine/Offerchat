@Offerchat.module "AgentsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "agents/list/layout"
    regions:
      seatsRegion:  "#seats-region"
      agentsRegion: "#agents-region"

  class List.Agent extends App.Views.ItemView
    template:  "agents/list/agent"
    tagName:   "a"
    className: "agent-selection-item"
    triggers:
      "click":      "agent:selection:clicked"

  class List.Agents extends App.Views.CompositeView
    template:          "agents/list/agents"
    className:         "block large group"
    itemView:          List.Agent
    itemViewContainer: "div#agent-list"


  class List.Seats extends App.Views.CompositeView
    template:  "agents/list/seats"
    className: "go-right align-right"

  class List.ShowAgent extends App.Views.ItemView
    template:  "agents/list/show_agent"
    form:
      buttons:
        primary: "Save Changes"
        cancel: false
        placement: "right"