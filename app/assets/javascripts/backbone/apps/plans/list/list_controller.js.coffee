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
        if @isDowngrade(plan)
          @showDowngradeModal(plan)
        else
          @showModal(plan)

    isDowngrade: (plan) ->
      current_plan = @profile.get("plan_identifier")
      if current_plan == "PERSONAL"
        if plan == "STARTER"
          true
        else
          false
      else if current_plan == "BUSINESS"
        if plan == "STARTER"
          true
        else if plan == "PERSONAL"
          true
        else
          false
      else if current_plan == "ENTERPRISE"
        false
      else if current_plan == "STARTER"
        true

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

    getDowngradeModal: (plan) ->
      new List.ModalDowngrade
        model: @profile
        plan: plan

    getAgentList: (agents) ->
      new List.Agents
        collection: agents

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

    showDowngradeModal: (plan) ->
      agents = App.request "agents:only:entities"
      plans = App.request "get:plan:by:name", plan

      App.execute "when:fetched", agents, =>
        modalView  = @getDowngradeModal(plan)
        formView = App.request "modal:wrapper", modalView
        agentsView = @getAgentList(agents)


        App.execute "when:fetched", plans, =>
          @listenTo agentsView, "agent:clicked", (e) ->
            next_plan = plans.first()

            # T0d0: Check the agent limits here

            $(e.currentTarget).parent().toggleClass "checked"
            $(e.currentTarget).parent().toggleClass "disabled"

        @listenTo formView, "show", ->
          modalView.agentsRegion.show agentsView

        @listenTo formView, "modal:cancel", (item) ->
          formView.close()

        App.modalRegion.show formView

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