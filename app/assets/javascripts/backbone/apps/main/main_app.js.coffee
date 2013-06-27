@Offerchat.module "MainApp", (MainApp, App, Backbone, Marionette, $, _) ->

  class MainApp.Router extends Marionette.AppRouter
    appRoutes:
      "" : "show"

  API =
    show: ->
      new MainApp.Show.Controller
        region: App.mainRegion
  
  App.addInitializer ->
    new MainApp.Router
      controller: API