@Offerchat.module "WebsitesApp", (WebsitesApp, App, Backbone, Marionette, $, _) ->

  class WebsitesApp.Router extends Marionette.AppRouter
    appRoutes:

      "websites"         : "list"
      "websites/new"     : "new"
      "websites/preview" : "preview"


  API =
    list: ->
      new WebsitesApp.List.Controller
        region: App.mainRegion


    new: ->
      new WebsitesApp.New.Controller
        region: App.mainRegion

    preview: ->
      new WebsitesApp.Preview.Controller
        region: App.previewRegion

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