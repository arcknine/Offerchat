@Offerchat.module "PlansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "plans/list/layout"
    className: "column-content-container"
    modelEvents:
      "change" : "render"
    events:
      "click a.upgrade" : "upgradePlan"
    triggers:
      "click a.close"   : "hide:notification"

    upgradePlan: (e) ->
      @trigger "upgrade:plan", e

    serializeData: ->
      plans = @options.plans.toJSON()

      user: @options.model.toJSON()
      starter:    plans[1]
      personal:   plans[2]
      business:   plans[3]
      enterprise: plans[4]

  class List.ModalPlan extends App.Views.ItemView
    template: "plans/list/modal"
    className: "form form-inline"
    form:
      title: "Upgrade Plan"
      terms: true
      footer: false
      buttons:
        nosubmit: false
        primary: false
        cancel: false

    triggers:
      "click .authorize-payment" : "authorize:payment"

    serializeData: ->
      user: @options.model.toJSON()
      plan: @options.plan
