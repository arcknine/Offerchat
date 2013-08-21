@Offerchat.module "ReportsApp", (ReportsApp, App, Backbone, Marionette, $, _) ->

  class ReportsApp.Router extends Marionette.AppRouter
    appRoutes:
      "reports" : "reports"

    API =
      reports: ->
        new ReportsApp.Show.Controller

    App.addInitializer ->
      new ReportsApp.Router
        controller: API