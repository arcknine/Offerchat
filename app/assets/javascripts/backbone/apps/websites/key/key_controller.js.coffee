@Offerchat.module "WebsitesApp.Key", (Key, App, Backbone, Marionette, $, _) ->

  class Key.Controller extends App.Controllers.Base

    initialize: (options = {}) ->


      newWebsite = App.request "site:new:entity"

      console.log 'data sa website',newWebsite
      newSiteView = @getWebsiteKeyView newWebsite
      App.mainRegion.show newSiteView

      @listenTo newSiteView, "click:finish:website", (item) ->
        App.navigate "#", trigger: true

      @listenTo newSiteView, "click:send:code", (item) ->
        console.log 'na click ang send code sa webmaster'

      @listenTo newSiteView, "click:install:guide", (item) ->
        console.log 'na click ang install guide'


    getWebsiteKeyView: (site) ->
      new Key.Code
        model: site