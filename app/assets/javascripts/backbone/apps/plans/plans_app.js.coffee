@Offerchat.module "PlansApp", (PlansApp, App, Backbone, Marionette, $, _) ->

  class PlansApp.Router extends Marionette.AppRouter
    appRoutes:
      "plans"         : "list"

  API =
    list: ->
      new PlansApp.List.Controller
        region: App.mainRegion

  App.addInitializer ->
    new PlansApp.Router
      controller: API