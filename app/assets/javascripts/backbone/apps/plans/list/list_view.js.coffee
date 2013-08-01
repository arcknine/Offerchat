@Offerchat.module "PlansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "plans/list/layout"
    className: "column-content-container"

    serializeData: ->
      plans = @options.plans.toJSON()

      starter:    plans[1]
      personal:   plans[2]
      business:   plans[3]
      enterprise: plans[4]
