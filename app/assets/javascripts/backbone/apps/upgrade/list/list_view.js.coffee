@Offerchat.module "UpgradeApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "upgrade/list/layout"
    className: "column-content-container"
    modelEvents:
      "all" : "render"

    triggers:
      "click a.view-all-agents" : "goto:agent:management"

    events:
      "click a.action" : "changePlan"

    changePlan: (e) ->
      @trigger "change:plan", e

    serializeData: ->
      plans = @options.plans.toJSON()

      basic: plans[5]
      pro: plans[6]
      profile: @options.model.toJSON()

  class List.ModalPlan extends App.Views.ItemView
    template: "upgrade/list/modal"
    className: "form form-inline"
    form:
      title: "Payment Details"
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

  class List.ModalProcessPayment extends App.Views.ItemView
    template: "upgrade/list/process_payment"
    className: "authorize-payment-overlay text-center"
    form:
      title: "Processing Payment"
      footer: false
      buttons:
        nosubmit: true

  class List.ModalPaymentSuccess extends App.Views.ItemView
    template: "upgrade/list/payment_success"
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
    template: "upgrade/list/payment_fail"
    className: "authorize-payment-overlay text-center"
    form:
      title: "Payment Failed"
      footer: false
      buttons:
        nosubmit: true
    triggers:
      "click .back-to-checkout" : "back:to:checkout"
    backToCheckout: (e) ->
      @trigger "back:to:checkout", e