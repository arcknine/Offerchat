@Offerchat.module "WebsitesApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      App.previewRegion.close()
      # App.vent.trigger "show:wizard:sidebar"
      sessionStorage.clear()
      sites = App.request "get:sites:count"

      App.execute "when:fetched", sites, =>
        console.log "number of websites = " +sites.length

      if sites.length is 0
        console.log "awa"
        App.vent.trigger "show:wizard:sidebar"
        $('#chat-sidebar-region').attr('class', 'tour-sidebar')

      currentUser = App.request "set:current:user", App.request "get:current:user:json"
      newSite     = App.request "site:new:entity"
      newSite.url = Routes.signup_wizard_path('step_three')
      newSite.set id:'step_three'
      console.log "new site", newSite

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