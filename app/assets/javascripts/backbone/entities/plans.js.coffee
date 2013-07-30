@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Plan extends Entities.Model

  class Entities.PlansCollection extends Entities.Collection
    model: Entities.Plan
    url: Routes.plans_path()

  API =
    getPlans: ->
      plans = new Entities.PlansCollection
      App.request "show:preloader"
      plans.fetch
        reset: true
        success: ->
          App.request "hide:preloader"
        error: ->
          App.request "hide:preloader"
      plans

  App.reqres.setHandler "get:plans", ->
    API.getPlans()