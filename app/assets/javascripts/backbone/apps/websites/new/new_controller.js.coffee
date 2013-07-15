@Offerchat.module "WebsitesApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      currentUser = App.request "set:current:user", App.request "get:current:user:json"
      newSite     = App.request "site:new:entity"
      newSite.url = Routes.signup_wizard_path('step_three')
      newSite.set id:'step_three'

      @listenTo newSite, "updated", (model) =>
        App.reqres.setHandler "set:session:new:website", ->
          model

        App.navigate "websites/preview", trigger: true

      newSiteView = @getNewWebsiteView newSite, currentUser

      formView  = App.request "form:wrapper", newSiteView

      App.mainRegion.show formView

    getNewWebsiteView: (site, currentUser) ->
      new New.Website
        model: site
        currentUser: currentUser