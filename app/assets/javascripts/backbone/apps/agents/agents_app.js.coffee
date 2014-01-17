@Offerchat.module "AgentsApp", (AgentsApp, App, Backbone, Marionette, $, _) ->

  class AgentsApp.Router extends Marionette.AppRouter
    appRoutes:
      "agents"     : "manage"

  API =
    manage: ->
      new AgentsApp.Manage.Controller
        region: App.mainRegion

  App.addInitializer ->
    new AgentsApp.Router
      controller: API