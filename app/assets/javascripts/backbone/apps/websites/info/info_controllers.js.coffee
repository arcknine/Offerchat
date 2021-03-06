@Offerchat.module "WebsitesApp.Info", (Info, App, Backbone, Marionette, $, _) ->

  class Info.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      sites = App.request "get:all:sites"
      # App.vent.trigger "show:chat:sidebar"
      @storage = JSON.parse(sessionStorage.getItem("newSite"))
      newWebsite = App.request "new:site:entity"
      newWebsite.url = Routes.websites_path()
      newSiteView = @getWebsiteInfoView newWebsite
      formView  = App.request "form:wrapper", newSiteView
      App.mainRegion.show formView

      @listenTo newWebsite, "created", (model) =>
        @storage.api_key = model.get('api_key')
        sessionStorage.setItem("newSite", JSON.stringify(@storage))
        App.navigate 'websites/key', trigger: true

      @initInfoView sites

      mixpanel.track("Add Website Info")

    getWebsiteInfoView: (site) ->
      new Info.Website
        model: site

    initInfoView: (sites) ->
      $('#connecting-region').remove();
      $('.opacity').remove();
      if sites.length is 0
        $('#preview-checklist').addClass('checked')
        $('#preview-checklist').find('span').hide()
        $('#second-check').removeClass('hide')
        $('#second-check').show()




