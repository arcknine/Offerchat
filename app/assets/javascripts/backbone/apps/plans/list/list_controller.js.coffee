@Offerchat.module "PlansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      plans = App.request "get:plans"
      @profile = App.request "get:current:user"

      @plansView = @getPlansView plans

      @listenTo @profile, "change", =>
        @initPlans(@profile.get("plan_identifier"))

      @listenTo @plansView, "hide:notification", =>
        $(".payment-notify").fadeOut()

      App.execute "when:fetched", plans, =>
        App.mainRegion.show @plansView
        @initPlans(@profile.get("plan_identifier"))

      @listenTo @plansView, "upgrade:plan", (e) =>
        plan = $(e.currentTarget).data('id')
        @showModal(plan)

    initPlans: (plan) ->
      $(".starter-plan-notice").addClass "hide"
      $(".free-plan-notice").addClass "hide"
      $(".group.starter-upgrade").removeClass "hide"

      if plan == "PERSONAL"
        $("#personal-button").html('<i class="icon icon-check-large-2"></i>')
      else if plan == "BUSINESS"
        $("#business-button").html('<i class="icon icon-check-large-2"></i>')
      else if plan == "ENTERPRISE"
        $("#enterprise-button").html('<i class="icon icon-check-large-2"></i>')
      else if plan == "STARTER"
        $(".group.starter-upgrade").addClass("hide")
        $(".starter-plan-notice").removeClass("hide")
      else if plan == "FREE"
        $(".free-plan-notice").removeClass("hide")

    getPlansView: (plans) ->
      new List.Layout
        plans: plans
        model: @profile

    getPlanModal: (plan) ->
      new List.ModalPlan
        model: @profile
        plan: plan

    getProcessPaymentModal: ->
      new List.ModalProcessPayment
        model: @profile

    getPaymentSuccessModal: ->
      new List.ModalPaymentSuccess
        model: @profile

    getPaymentFailModal: ->
      new List.ModalPaymentFail
        model: @profile

    showModal: (plan) =>
      modalView = @getPlanModal(plan)

      formView  = App.request "modal:wrapper", modalView
      App.modalRegion.show formView

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      @listenTo modalView, "authorize:payment", (e) =>
        Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))

        @processPayment()

        card =
          number:   $(e.view.el).find("input[name=credit_card_number]").val()
          cvc:      $(e.view.el).find("input[name=cvv]").val()
          expMonth: $(e.view.el).find("input[name=month]").val()
          expYear:  $(e.view.el).find("input[name=year]").val()

        handleStripeResponse = (status, response) =>
          if status == 200
            $.post "/subscriptions",
              plan_id: plan
              card_token: response.id
            , (data) =>
              @profile.set { plan_identifier: plan }

              App.reqres.setHandler "get:current:user", =>
                @profile

              @paymentSuccess()
          else
            @paymentFail()

        Stripe.createToken(card, handleStripeResponse)

    processPayment: =>
      modalView = @getProcessPaymentModal()
      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      App.modalRegion.show formView

    paymentSuccess: =>
      modalView = @getPaymentSuccessModal()
      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      @listenTo modalView, "goto:agents", (item) ->
        formView.close()
        App.navigate Routes.agents_path(), trigger: true

      App.modalRegion.show formView

    paymentFail: =>
      modalView = @getPaymentFailModal()
      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:cancel", (item) ->
        formView.close()

      App.modalRegion.show formView