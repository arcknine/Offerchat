@Offerchat.module "PlansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "plans/list/layout"
    className: "column-content-container"
    events:
      "click a.upgrade" : "upgradePlan"

    upgradePlan: (e) ->
      console.log e
      @trigger "upgrade:plan", e

    serializeData: ->
      plans = @options.plans.toJSON()

      starter:    plans[1]
      personal:   plans[2]
      business:   plans[3]
      enterprise: plans[4]

  class List.ModalPlan extends App.Views.ItemView
    template: "plans/list/modal"
    className: "form form-inline"
    form:
      title: "Upgrade Plan"