@Offerchat.module "PlansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      plans = App.request "get:plans"
      @profile = App.request "get:current:profile"

      $(window).resize ->
        $("#main-region > .column-content-container").css("height", ($(window).height() - 45) + "px")

      @plansView = @getPlansView plans

      @listenTo @profile, "change", =>
        pid = @profile.get("plan_identifier")
        @initPlans(pid)
        @profile.set trial: pid == "PREMIUM" ? true : false
        $("#premium-trial").addClass("hide")

      @listenTo @plansView, "hide:notification", =>
        $(".payment-notify").fadeOut()

      App.execute "when:fetched", plans, =>
        App.mainRegion.show @plansView
        @initPlans(@profile.get("plan_identifier"))

        height = ($(window).height() - 45) + "px"
        $("#main-region > .column-content-container").css("height", height)

      @listenTo @plansView, "upgrade:plan", (e) =>
        plan = $(e.currentTarget).data('id')
        if @isDowngrade(plan)
          @showDowngradeModal(plan)
        else
          @showModal(plan)
          
        # track upgrage click
        mixpanel.track("Click #{plan} Plan")
          
      # track viewing Plans
      mixpanel.track("View Plans Page")

      @coupons = App.request "get:coupons"

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
        true
      else if current_plan == "PREMIUM"
        true
      else if current_plan == "STARTER"
        false

    initPlans: (plan) ->
      $(".starter-plan-notice").addClass "hide"
      $(".free-plan-notice").addClass "hide"
      $(".group.starter-upgrade").removeClass "hide"
      $(".premium-trial-notice").addClass("hide")

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
      else if plan == "PREMIUM"
        $(".premium-trial-notice").removeClass("hide")

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

    showModal: (plan, agents=null) =>
      modalView = @getPlanModal(plan)

      formView  = App.request "modal:wrapper", modalView
      App.modalRegion.show formView

      @listenTo formView, "modal:cancel", (item)->
        formView.close()
        
        # track upgrade cancellation
        mixpanel.track("Cancel #{plan} Plan")

      @listenTo modalView, "authorize:payment", (e) =>
        # track payment authorize
        mixpanel.track("Authorizing Payment")
        
        coupon_code = $.trim($(e.view.el).find("input[name=coupon]").val())

        if @validCoupon(coupon_code, e)

          Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))

          card =
            number:   $(e.view.el).find("input[name=credit_card_number]").val()
            cvc:      $(e.view.el).find("input[name=cvv]").val()
            expMonth: $(e.view.el).find("input[name=month]").val()
            expYear:  $(e.view.el).find("input[name=year]").val()

          if @validateCard(card, e)
            @processPayment()

            handleStripeResponse = (status, response) =>
              if status == 200
                if agents != null
                  agent_params = _.map(agents.models, (a, k) ->
                    [a.get("id"), a.get("enabled")])

                $.post "/subscriptions",
                  plan_id: plan
                  card_token: response.id
                  coupon: coupon_code unless coupon_code is ""
                  agents: agent_params unless agents is null
                , (data) =>
                  @profile.set { plan_identifier: plan }

                  App.reqres.setHandler "get:current:user", =>
                    @profile

                  @paymentSuccess()
              else
                @paymentFail(plan)

            Stripe.createToken(card, handleStripeResponse)
        
    validCoupon: (coupon, e) ->
      if coupon isnt ""
        res = @coupons.findWhere id: coupon
        if res
          true
        else
          $(e.view.el).find("input[name=coupon]").parent().parent().addClass("field-error")
          $(e.view.el).find("input[name=coupon]").next().removeClass("hide")
          false
      else
        true

    showDowngradeModal: (plan) =>
      agents       = App.request "agents:only:entities"
      new_plan     = App.request "get:plan:by:name", plan
      current_plan = App.request "get:plan:by:name", @profile.get("plan_identifier")

      @checked_agents = 1

      App.execute "when:fetched", agents, =>
        App.execute "when:fetched", new_plan, =>
          App.execute "when:fetched", current_plan, =>

            if agents.length == 0
              @showModal(plan)
            else
              modalView  = @getDowngradeModal(new_plan.first())
              formView   = App.request "modal:wrapper", modalView
              agentsView = @getAgentList(agents)

              next          = new_plan.first()
              new_max_seats = next.get("max_agent_seats")

              prev          = current_plan.first()
              old_max_seats = prev.get("max_agent_seats")

              used_seats    = agents.length

              @listenTo agentsView, "childview:agent:clicked", (e) =>
                agent_model = e.model
                enabled = agent_model.get("enabled")

                if typeof(enabled) == "undefined" || enabled == false
                  if @checked_agents < new_max_seats
                    agent_model.set({class_names: "checked"})
                    agent_model.set({enabled: true})
                    @changeSeatCount(agent_model)
                else
                  agent_model.set({class_names: ""})
                  agent_model.set({enabled: false})
                  @changeSeatCount(agent_model)

              @listenTo modalView, "proceed:downgrade", (e) =>
                @showModal(plan, agents)

              @listenTo formView, "show", =>
                modalView.agentsRegion.show agentsView

              @listenTo formView, "modal:cancel", (item) =>
                formView.close()

              App.modalRegion.show formView

    processPayment: =>
      modalView = @getProcessPaymentModal()
      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      App.modalRegion.show formView
      
      # track Payment processing
      mixpanel.track("Processing Payment")

    paymentSuccess: =>
      modalView = @getPaymentSuccessModal()
      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      @listenTo modalView, "goto:agents", (item) ->
        formView.close()
        App.navigate Routes.agents_path(), trigger: true

      App.modalRegion.show formView
      
      # track Payment processing
      mixpanel.track("Payment Successful")

    paymentFail: (plan) =>
      modalView = @getPaymentFailModal()
      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:cancel", (item) ->
        formView.close()

      @listenTo modalView, "back:to:checkout", (e) ->
        @showModal(plan)

      App.modalRegion.show formView

    changeSeatCount: (e) =>
      curr = $("#seat-count").text()

      if e.get("enabled")
        newnum = parseInt(curr) - 1
        $("#seat-count").html(newnum)
        @checked_agents++
      else
        newnum = parseInt(curr) + 1
        $("#seat-count").html(newnum)
        @checked_agents--

    validateCard: (card, e) =>
      $("fieldset").removeClass("field-error")
      $(".block-text-message").addClass("hide")

      valid = true
      if card.number == ""
        $(e.view.el).find("input[name=credit_card_number]").parent().parent().addClass("field-error")
        $(e.view.el).find("input[name=credit_card_number]").next().removeClass("hide")
        valid = false

      if card.cvc == ""
        $(e.view.el).find("input[name=cvv]").parent().parent().addClass("field-error")
        $(e.view.el).find("input[name=cvv]").next().removeClass("hide")
        valid = false

      if card.expMonth == "" || card.expYear == ""
        $(e.view.el).find("input[name=month]").parent().parent().addClass("field-error")
        $(e.view.el).find("input[name=year]").next().removeClass("hide")
        valid = false

      if !card.number.match(/^\d+$/)
        $(e.view.el).find("input[name=credit_card_number]").parent().parent().addClass("field-error")
        $(e.view.el).find("input[name=credit_card_number]").next().removeClass("hide")
        valid = false

      if !card.cvc.match(/^\d+$/)
        $(e.view.el).find("input[name=cvv]").parent().parent().addClass("field-error")
        $(e.view.el).find("input[name=cvv]").next().removeClass("hide")
        valid = false

      if !card.expMonth.match(/^\d+$/)
        $(e.view.el).find("input[name=month]").parent().parent().addClass("field-error")
        $(e.view.el).find("input[name=year]").next().removeClass("hide")
        valid = false

      return valid
