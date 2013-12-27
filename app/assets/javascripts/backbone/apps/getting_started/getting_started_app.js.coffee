@Offerchat.module "GettingStartedApp", (GettingStartedApp, App, Backbone, Marionette, $, _) ->

  class GettingStartedApp.Router extends Marionette.AppRouter
    appRoutes:
      "getting_started"                : "show"

    API =
      show: ->
        new GettingStartedApp.Show.Controller
          region: App.mainRegion

    App.addInitializer ->
      new GettingStartedApp.Router
        controller: API