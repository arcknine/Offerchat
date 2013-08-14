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


  class List.ModalDowngrade extends App.Views.Layout
    template: "plans/list/downgrade"
    className: "form form-inline"
    regions:
      agentsRegion: "#agents-region"
    form:
      title: "Downgrade Plan"
      terms: true
      footer: false
      buttons:
        nosubmit: false
        primary: false
        cancel: false

  class List.Agent extends App.Views.ItemView
    template:  "plans/list/agent"
    className: "agent-inline-block agent-block-large"

  class List.Agents extends App.Views.CompositeView
    template: "plans/list/agents"
    className: "block group agent-selection-form"
    itemView: List.Agent
    itemViewContainer: "#agent-list"

  class List.ModalProcessPayment extends App.Views.ItemView
    template: "plans/list/process_payment"
    className: "authorize-payment-overlay text-center"
    form:
      title: "Processing Payment"
      footer: false
      buttons:
        nosubmit: true

  class List.ModalPaymentSuccess extends App.Views.ItemView
    template: "plans/list/payment_success"
    className: "authorize-payment-overlay text-center"
    form:
      title: "Payment Successful"
      footer: false
      buttons:
        nosubmit: true

    triggers:
      "click .manage-agents" : "goto:agents"

    serializeData: ->
      user: @options.model.toJSON()

  class List.ModalPaymentFail extends App.Views.ItemView
    template: "plans/list/payment_fail"
    className: "authorize-payment-overlay text-center"
    form:
      title: "Payment Failed"
      footer: false
      buttons:
        nosubmit: true