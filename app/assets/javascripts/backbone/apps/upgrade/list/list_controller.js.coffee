@Offerchat.module "UpgradeApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->

      @profile = App.request "get:current:profile"

      @coupons = App.request "get:coupons"

      App.execute "when:fetched", @profile, =>

        @plans = App.request "get:plans"

        App.execute "when:fetched", @plans, =>

          agents = App.request "agents:entities", true

          current_plan = @profile.get("plan_identifier")
          @layout = @getLayout @plans

          @listenTo @layout, "show", =>
            @activeCurrentPlan(current_plan)

          @listenTo @layout, "change:plan", (e) =>
            @showModal(e, agents)

          @listenTo @layout, "goto:agent:management", =>
            App.navigate Routes.agents_path(), trigger: true

          App.execute "when:fetched", agents, =>
            @setAgentCount(agents, @plans)

          App.mainRegion.show @layout

    setAgentCount: (all_agents, all_plans) =>
      current_plan = @profile.get("plan_identifier")

      cplan = all_plans.findWhere plan_identifier: current_plan
      plan_price = cplan.get("price")
      plan_price = 0 if current_plan is "TRIAL"

      if all_agents.length > 0
        res = all_agents.length * plan_price
        $(".agent-count").html(all_agents.length)
        $(".price-plan").html(res.toFixed(2))
      else
        $(".agents-info").remove()

    activeCurrentPlan: (current_plan) =>
      current_plan_html = "<span class='icon-round-check'><i class='icon icon-check-large'></i></span>This is your current plan"
      if current_plan is "PRO" or current_plan is "TRIAL" or current_plan is "ENTERPRISE"
        elem = $(".pro-plan")
      else if current_plan is "BASIC"
        elem = $(".basic-plan")

      if elem
        elem.addClass("active")
        elem.find(".plan-action").html(current_plan_html)

    showModal: (elem, agents) =>
      target_plan = $(elem.currentTarget).attr("id")
      modal = @getModalView target_plan

      formView  = App.request "modal:wrapper", modal

      @listenTo formView, "modal:cancel", (item) ->
        formView.close()

        # track upgrade cancellation
        mixpanel.track("Cancel #{target_plan} Plan")

      @listenTo modal, "authorize:payment", (e) =>

        agents_qty = agents.length

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
                  plan_id: target_plan
                  card_token: response.id
                  coupon: coupon_code unless coupon_code is ""
                  qty: agents_qty
                  # agents: agent_params unless agents is null
                , (data) =>
                  @profile.set { plan_identifier: target_plan }

                  @activeCurrentPlan(target_plan)
                  @setAgentCount(agents, @plans)

                  App.reqres.setHandler "get:current:user", =>
                    @profile

                  @paymentSuccess()
              else
                @paymentFail(target_plan)

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

    paymentFail: (plan) =>
      modalView = @getPaymentFailModal()
      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:cancel", (item) ->
        formView.close()

      @listenTo modalView, "back:to:checkout", (e) ->
        @showModal(e, plan)

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

    getModalView: (plan) ->
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