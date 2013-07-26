@Offerchat.module "AgentsApp", (AgentsApp, App, Backbone, Marionette, $, _) ->

  class AgentsApp.Router extends Marionette.AppRouter
    appRoutes:
      "agents" : "list"

  API =
    list: ->
      new AgentsApp.List.Controller
        region: App.mainRegion

  App.addInitializer ->
    new AgentsApp.Router
      controller: API