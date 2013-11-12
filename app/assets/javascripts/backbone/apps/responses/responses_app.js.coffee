@Offerchat.module "ResponsesApp", (ResponsesApp, App, Backbone, Marionette, $, _) ->

  class ResponsesApp.Router extends Marionette.AppRouter
    appRoutes:
      "quick-responses"            : "qsr"

    API =
      qsr: ->
        new ResponsesApp.List.Controller
          region: App.mainRegion

    App.addInitializer ->
      new ResponsesApp.Router
        controller: API