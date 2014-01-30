@Offerchat.module "UpgradeApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->

      @profile = App.request "get:current:profile"

      @coupons = App.request "get:coupons"

      App.request "show:preloader"

      App.execute "when:fetched", @profile, =>

        # check if user has plan
        unless @profile.get("plan_identifier")
          App.navigate "/", trigger: true
        else

          @plans = App.request "get:plans"

          App.execute "when:fetched", @plans, =>

            agents = App.request "agents:entities", true

            current_plan = @profile.get("plan_identifier")
            @layout = @getLayout @plans

            @listenTo @layout, "show", =>
              @activeCurrentPlan(current_plan)
              @informTrialPeriod()

            @listenTo @layout, "change:plan", (e) =>
              @showModal(e, agents)

            @listenTo @layout, "goto:agent:management", =>
              App.navigate Routes.agents_path(), trigger: true

            App.execute "when:fetched", agents, =>
              @setAgentCount(agents, @plans)

            App.mainRegion.show @layout

        App.request "hide:preloader"

    informTrialPeriod: =>
      current_plan = @profile.get('plan_identifier')
      if current_plan is "PROTRIAL"
        days_left = @profile.get('trial_days_left')
        if days_left > 0
          notice = "You have <strong>#{days_left} days</strong> left in your trial. Select one of our plans below to continue using our service."
          $(".block-message").removeClass("hide").html(notice)

    setAgentCount: (all_agents, all_plans) =>
      current_plan = @profile.get("plan_identifier")

      cplan = all_plans.findWhere plan_identifier: current_plan
      if ["PROTRIAL", "AFFILIATE"].indexOf(current_plan) isnt -1
        plan_price = 0
      else
        plan_price = cplan.get("price")

      if all_agents.length > 0
        res = all_agents.length * plan_price

        # get plan price if not pro or basic
        res = plan_price if ["PRO", "BASIC"].indexOf(current_plan) is -1

        $(".agent-count").html(all_agents.length)
        $(".price-plan").html(res.toFixed(2))
      else
        $(".agents-info").remove()

    activeCurrentPlan: (current_plan) =>
      current_plan_html = "<span class='icon-round-check'><i class='icon icon-check-large'></i></span>This is your current plan"
      if current_plan is "PRO"
        elem = $(".pro-plan")
      else if current_plan is "BASIC"
        elem = $(".basic-plan")
      else if ["PROTRIAL", "AFFILIATE"].indexOf(current_plan) isnt -1
        # do nothing
      else
        notice = "Your current plan is part of our legacy pricing model. Once you upgrade to our <strong>Basic / Pro plan</strong> you cannot undo this."
        $(".block-message").removeClass("hide").html(notice)

      if elem
        elem.addClass("active")
        elem.find(".plan-action").html(current_plan_html)

      # change caps of the plan name
      plan_elem = $(".plan-name")
      plan_name = @normalizeString(plan_elem.html())
      plan_elem.html(plan_name)


    normalizeString: (str) =>
      res = $.trim(str.toLowerCase())
      if res is "protrial"
        res = "Pro Trial"
      else
        res = res.charAt(0).toUpperCase() + res.slice(1)
      res

    showModal: (elem, agents) =>
      target_plan = $(elem.currentTarget)
      target_id = target_plan.attr("id")
      target_price = target_plan.data("price")

      agents_qty = agents.length

      modal = @getModalView target_id, agents_qty

      formView  = App.request "modal:wrapper", modal

      @listenTo formView, "show", =>
        res = target_price * agents_qty
        $(".monthly-due").html(res.toFixed(2))

        plan_name = @normalizeString target_id
        $(".plan-name-in-modal").html(plan_name)


      @listenTo formView, "modal:cancel", (item) ->
        formView.close()

        # track upgrade cancellation
        mixpanel.track("Cancel #{target_id} Plan")

      @listenTo modal, "authorize:payment", (e) =>

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

                $.post "/subscriptions",
                  plan_id: target_id
                  card_token: response.id
                  coupon: coupon_code unless coupon_code is ""
                  qty: agents_qty
                  # agents: agent_params unless agents is null
                , (data) =>
                  @profile.set { plan_identifier: target_id }

                  @activeCurrentPlan(target_id)
                  @setAgentCount(agents, @plans)

                  App.reqres.setHandler "get:current:user", =>
                    @profile

                  App.execute "plan:changed", target_id

                  @paymentSuccess()
              else
                @paymentFail(target_id, target_price, agents, response.error.message)

            Stripe.createToken(card, handleStripeResponse)


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

      # track Payment processing
      mixpanel.track("Payment Successful")

    paymentFail: (plan, price, agents, err_msg) =>
      modalView = @getPaymentFailModal(plan, price, err_msg)
      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:cancel", (item) ->
        formView.close()

      @listenTo modalView, "back:to:checkout", (e) ->
        @showModal(e, agents)

      App.modalRegion.show formView

    processPayment: =>
      modalView = @getProcessPaymentModal()
      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      App.modalRegion.show formView

      # track Payment processing
      mixpanel.track("Processing Payment")

    getLayout: (plans) ->
      new List.Layout
        model: @profile
        plans: plans

    getModalView: (plan, qty) ->
      new List.ModalPlan
        model: @profile
        plan: plan
        qty: qty

    getProcessPaymentModal: ->
      new List.ModalProcessPayment
        model: @profile

    getPaymentSuccessModal: ->
      new List.ModalPaymentSuccess
        model: @profile

    getPaymentFailModal: (plan, price, err_msg) ->
      new List.ModalPaymentFail
        model: @profile
        plan: plan
        price: price
        error: err_msg


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