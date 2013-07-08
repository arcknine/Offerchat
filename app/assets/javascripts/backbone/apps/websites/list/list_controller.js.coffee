@Offerchat.module "WebsitesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      websiteView = @getMainView()

      console.log websiteView
      App.mainRegion.show websiteView

    getMainView: ->
      new List.Websites