@Offerchat.module "WebsitesApp.Key", (Key, App, Backbone, Marionette, $, _) ->

  class Key.Controller extends App.Controllers.Base

    initialize: (options = {}) ->


      newWebsite = App.request "site:new:entity"

      console.log 'data sa website',newWebsite
      newSiteView = @getWebsiteKeyView newWebsite
      App.mainRegion.show newSiteView

    getWebsiteKeyView: (site) ->
      new Key.Code
        model: site