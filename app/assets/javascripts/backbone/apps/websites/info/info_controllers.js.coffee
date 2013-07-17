@Offerchat.module "WebsitesApp.Info", (Info, App, Backbone, Marionette, $, _) ->

  class Info.Controller extends App.Controllers.Base

    initialize: (options = {}) ->

      @storage = JSON.parse(sessionStorage.getItem("newSite"))
      newWebsite = App.request "site:new:entity"
      newWebsite.url = Routes.websites_path()
      newSiteView = @getWebsiteInfoView newWebsite
      formView  = App.request "form:wrapper", newSiteView
      App.mainRegion.show formView

      @listenTo newWebsite, "created", (model) =>
        console.log 'waaaaaaaa', model
        @storage.api_key = model.get('api_key')
        sessionStorage.setItem("newSite", JSON.stringify(@storage))
        App.navigate 'websites/key', trigger: true




    getWebsiteInfoView: (site) ->
      new Info.Website
        model: site
