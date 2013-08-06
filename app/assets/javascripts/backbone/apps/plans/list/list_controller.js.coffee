@Offerchat.module "PlansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      plans = App.request "get:plans"
      @profile = App.request "get:current:profile"

      plansView = @getPlansView plans
      App.execute "when:fetched", plans, =>
        App.mainRegion.show plansView

      @listenTo plansView, "upgrade:plan", (e) =>
        plan = $(e.currentTarget).data('id')
        console.log plan
        @showModal(plan)

    getPlansView: (plans) ->
      new List.Layout
        plans: plans

    getPlanModal: (plan) ->
      new List.ModalPlan
        model: @profile
        plan: plan

    showModal: (plan) ->
      modalView = @getPlanModal(plan)

      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:close", (item)->
        formView.close()

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      App.modalRegion.show formView