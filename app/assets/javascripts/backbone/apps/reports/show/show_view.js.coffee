@Offerchat.module "ReportsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  class Show.Reports extends App.Views.ItemView
    template: "reports/show/show"
    className: "block large"
    events:
      "click a.agent-inline-block": "toggleAgent"
    toggleAgent: (e) ->
      console.log(e.target)
      $(e.target).addClass "selected"