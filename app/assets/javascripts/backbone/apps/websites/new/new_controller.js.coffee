@Offerchat.module "WebsitesApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      @profile = App.request "get:current:profile"

      App.execute "when:fetched", @profile, =>
        plan = @profile.get("plan_identifier")
        if ["PROTRIAL", "AFFILIATE", "BASIC", "", null].indexOf(plan) isnt -1
          App.navigate "/", trigger: true
        else

          App.previewRegion.close()
          sessionStorage.clear()

          currentUser = App.request "set:current:user", App.request "get:current:user:json"
          newSite     = App.request "new:site:entity"
          newSite.url = Routes.signup_wizard_path('step_three')
          newSite.set id:'step_three'

          @listenTo newSite, "updated", (model) =>

            currentUrl    = model.get("url")
            newUrl        = @cleanWebsiteUrl currentUrl
            model.set url = newUrl
            storage       = JSON.parse(sessionStorage.getItem("newSite")) || {}
            storage.url   = newUrl

            sessionStorage.setItem("newSite", JSON.stringify(storage))

            App.navigate "websites/preview", trigger: true

          newSiteView = @getNewWebsiteView newSite, currentUser

          formView  = App.request "form:wrapper", newSiteView

          App.mainRegion.show formView

          mixpanel.track("Add New Website")

    getNewWebsiteView: (site, currentUser) ->
      new New.Website
        model: site
        currentUser: currentUser

    wizardToggle: ->
      App.vent.trigger "show:wizard:sidebar"
      $('#chat-sidebar-region').attr('class', 'tour-sidebar')

    cleanWebsiteUrl: (url) ->
      url = "http://" + url  unless /^(f|ht)tps?:\/\//i.test(url)
      url
