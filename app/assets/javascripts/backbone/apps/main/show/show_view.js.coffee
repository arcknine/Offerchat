@Offerchat.module "MainApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Main extends App.Views.ItemView
    template: "main/show/main"
    className: "main-inner"

  class Show.OwnerMain extends App.Views.Layout
    template: "main/show/owner_main"
    regions:
      chatSummary:    "#chat-summary"
      latAgentActive: "#last-agent-active"

  class Show.ChatSummary extends App.Views.ItemView
    template:  "main/show/chat_summary"
    className: "block large bordered-bottom"
    modelEvents:
      "change" : "render"

  class Show.Agent extends App.Views.ItemView
    template:  "main/show/agent"
    tagName:   "li"
    modelEvents:
      "change" : "render"

  class Show.Agents extends App.Views.CompositeView
    template:  "main/show/agents"
    className: "block large"
    itemView:  Show.Agent
    itemViewContainer: "ul.active-agents-list"
    collectionEvents:
      "change" : "render"
