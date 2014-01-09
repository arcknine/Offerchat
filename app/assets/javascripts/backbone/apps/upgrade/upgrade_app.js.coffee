@Offerchat.module "UpgradeApp", (UpgradeApp, App, Backbone, Marionette, $, _) ->

  class UpgradeApp.Router extends Marionette.AppRouter
    appRoutes:
      "upgrade"         : "list"

  API =
    list: ->
      new UpgradeApp.List.Controller
        region: App.mainRegion

  App.addInitializer ->
    new UpgradeApp.Router
      controller: API