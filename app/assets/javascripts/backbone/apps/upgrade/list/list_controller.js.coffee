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

            @listenTo @layout, "open:update:billing:info", =>
              @showBillingInfoModal agents

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
      if ["PROTRIAL", "AFFILIATE", "OFFERFREE"].indexOf(current_plan) isnt -1
        plan_price = 0
      else
        plan_price = cplan.get("price")

      if all_agents.length > 0
        res = all_agents.length * plan_price

        # get plan price if not pro or basic
        res = plan_price if ["PRO", "BASIC", "PROYEAR", "PRO6MONTHS", "BASICYEAR", "BASIC6MONTHS"].indexOf(current_plan) is -1

        $(".agent-count").html(all_agents.length)
        $(".price-plan").html(res.toFixed(2))
      else
        $(".agents-info").remove()

    activeCurrentPlan: (current_plan) =>
      current_plan_html = "<span class='icon-round-check'><i class='icon icon-check-large'></i></span>This is your current plan"
      switch current_plan
        when "PRO", "PROYEAR", "PRO6MONTHS"
          elem = $(".pro-plan")
        when "BASIC", "BASICYEAR", "BASIC6MONTHS"
          elem = $(".basic-plan")
        when "PROTRIAL", "AFFILIATE", "OFFERFREE"
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

      $(document).on "change", ".payment-option", =>
        type      = $(modal.el).find("select[name=options]").val()
        switch type
          when "month"
            target_id = target_plan.attr("id")
          when "6months"
            target_id = "#{target_plan.attr("id")}6MONTHS"
          when "year"
            target_id = "#{target_plan.attr("id")}YEAR"

        # target_id = (if type is "month" then target_plan.attr("id") else "#{target_id}YEAR")
        plan      = @plans.findWhere plan_identifier: target_id
        price     = plan.get "price"
        total     = parseFloat(agents_qty * price).toFixed(2)
        # if type is "month"
        #   total = parseFloat(agents_qty * price).toFixed(2)
        # else
        #   total    = agents_qty * price
        #   # discount = total * (20/100)
        #   discount = 0
        #   total    = parseFloat(total - discount).toFixed(2)

        $(".monthly-due").text(total)

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

    processCardUpdate: ->
      modalView = @getProcessBillingInfo()
      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      App.reqres.setHandler "close:card:update:process", ->
        formView.close()

      App.modalRegion.show formView

    showBillingInfoModal: (agents) ->
      modalView = @getModalBillingInfo()
      formView  = App.request "modal:wrapper", modalView

      current_plan = @plans.findWhere plan_identifier: @profile.get("plan_identifier")
      target_id    = current_plan.get("plan_identifier")
      target_price = current_plan.get("price")

      @listenTo formView, "modal:cancel", (item) ->
        formView.close()

      @listenTo modalView, "update:billing:info", (e) =>
        Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
        card =
          number:   $(e.view.el).find("input[name=credit_card_number]").val()
          cvc:      $(e.view.el).find("input[name=cvv]").val()
          expMonth: $(e.view.el).find("input[name=month]").val()
          expYear:  $(e.view.el).find("input[name=year]").val()

        if @validateCard(card, e)
          @processCardUpdate()

          handleStripeResponse = (status, response) =>

            if status == 200

              $.post "/subscriptions/change_card",
                plan_id: target_id
                card_token: response.id
                card_id: response.card.id
                qty: agents.length
              , (data) =>
                @profile.set { plan_identifier: target_id }

                @activeCurrentPlan(target_id)
                @setAgentCount(agents, @plans)

                App.reqres.setHandler "get:current:user", =>
                  @profile

                App.execute "plan:changed", target_id
                App.request "close:card:update:process"
                @showNotification("Your billing info has been updated.")
            else
              App.request "close:card:update:process"
              # @paymentFail(target_id, target_price, agents, response.error.message)
              @showNotification("Failed to update your billing info.")

          Stripe.createToken(card, handleStripeResponse)

        false

      App.modalRegion.show formView


    getLayout: (plans) ->
      new List.Layout
        model: @profile
        plans: plans

    getModalView: (plan, qty) ->
      new List.ModalPlan
        model: @profile
        plan: plan
        qty: qty

    getModalBillingInfo: ->
      new List.BillingInfo
        model: @profile

    getProcessPaymentModal: ->
      new List.ModalProcessPayment
        model: @profile

    getProcessBillingInfo: ->
      new List.ProcessBillingInfo
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