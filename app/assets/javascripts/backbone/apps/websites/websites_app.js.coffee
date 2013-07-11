@Offerchat.module "WebsitesApp", (WebsitesApp, App, Backbone, Marionette, $, _) ->

  class WebsitesApp.Router extends Marionette.AppRouter
    appRoutes:
      "websites" : "list"
      "websites/new" : "show"
      "websites/preview" : "editSettings"

  API =
    list: ->
      new WebsitesApp.List.Controller
        region: App.mainRegion

    show: ->
      new WebsitesApp.Show.Controller
        region: App.mainRegion
        section: "new"

    editSettings:  ->
      new WebsitesApp.Show.Controller
        region: App.mainRegion
        section: 'preview'

  App.addInitializer ->
    new WebsitesApp.Router
      controller: API