@Offerchat.module "PlansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      plans = App.request "get:plans"
      @profile = App.request "get:current:user"

      @plansView = @getPlansView plans

      @listenTo @profile, "change", =>
        @initPlans(@profile.get("plan_identifier"))

      @listenTo layout, "hide:notification", =>
        $(".payment-notify").fadeOut()

      App.execute "when:fetched", plans, =>
        App.mainRegion.show @plansView
        @initPlans(@profile.get("plan_identifier"))

      @listenTo @plansView, "upgrade:plan", (e) =>
        plan = $(e.currentTarget).data('id')
        @showModal(plan)

    initPlans: (plan) ->
      console.log plan
      if plan == "PERSONAL"
        $("#personal-button").html('<i class="icon icon-check-large-2"></i>')
      else if plan == "BUSINESS"
        $("#business-button").html('<i class="icon icon-check-large-2"></i>')
      else if plan == "ENTERPRISE"
        $("#enterprise-button").html('<i class="icon icon-check-large-2"></i>')
      else if plan == "STARTER"
        console.log "waley"

    getPlansView: (plans) ->
      new List.Layout
        plans: plans
        model: @profile

    getPlanModal: (plan) ->
      new List.ModalPlan
        model: @profile
        plan: plan

    showModal: (plan) =>
      modalView = @getPlanModal(plan)

      formView  = App.request "modal:wrapper", modalView

      @listenTo modalView, "authorize:payment", (e) =>
        Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))

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

              formView.trigger "modal:close"
              @paymentNotify("<strong>Success!</strong> You have upgraded your subscription to <strong>#{plan}</strong>.", "success")
          else
            formView.trigger "modal:close"
            @paymentNotify("There was a problem with your credit card. Please try again later", "warning")

        Stripe.createToken(card, handleStripeResponse)

      @listenTo formView, "modal:close", (item)->
        formView.close()

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      App.modalRegion.show formView

    paymentNotify: (message, klass) ->
      $(".payment-notify").removeClass("success")
      $(".payment-notify").removeClass("warning")
      $(".payment-notify").addClass(klass)
      $(".payment-notify").find("span").html(message)
      $(".payment-notify").fadeIn()

