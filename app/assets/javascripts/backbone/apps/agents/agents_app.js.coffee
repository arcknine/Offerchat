@Offerchat.module "AgentsApp", (AgentsApp, App, Backbone, Marionette, $, _) ->

  class AgentsApp.Router extends Marionette.AppRouter
    appRoutes:
      "agents/old" : "list"
      "agents"     : "manage"

  API =
    list: ->
      new AgentsApp.List.Controller
        region: App.mainRegion

    manage: ->
      new AgentsApp.Manage.Controller
        region: App.mainRegion

  App.addInitializer ->
    new AgentsApp.Router
      controller: API