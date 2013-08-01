@Offerchat.module "PlansApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      plans = App.request "get:plans"

      App.execute "when:fetched", plans, =>
        plansView = @getPlansView plans

        App.mainRegion.show plansView

    getPlansView: (plans) ->
      new List.Layout
        plans: plans