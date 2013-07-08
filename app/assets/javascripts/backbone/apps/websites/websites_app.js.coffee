@Offerchat.module "WebsitesApp", (WebsitesApp, App, Backbone, Marionette, $, _) ->

  class WebsitesApp.Router extends Marionette.AppRouter
    appRoutes:
      "websites" : "list"

  API =
    list: ->
      new WebsitesApp.List.Controller
        region: App.mainRegion

  App.addInitializer ->
    new WebsitesApp.Router
      controller: API