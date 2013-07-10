@Offerchat.module "WebsitesApp", (WebsitesApp, App, Backbone, Marionette, $, _) ->

  class WebsitesApp.Router extends Marionette.AppRouter
    appRoutes:
      "websites" : "list"
      "websites/new" : "show"
      "websites/preview" : "show"

  API =
    list: ->
      new WebsitesApp.List.Controller
        region: App.mainRegion

    show: ->
      console.log "showwwww"
      new WebsitesApp.Show.Controller
        region: App.mainRegion

  App.addInitializer ->
    new WebsitesApp.Router
      controller: API