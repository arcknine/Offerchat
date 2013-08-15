@Offerchat.module "WebsitesApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      App.previewRegion.close()
      sessionStorage.clear()

      @initViews()

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

    initViews: ->
      sites = App.request "get:sites:count"
      if sites.length is 0
        App.vent.trigger "show:wizard:sidebar"
        $('#chat-sidebar-region').attr('class', 'tour-sidebar')
      App.execute "when:fetched", sites, =>
        if sites.lenght isnt 0
          App.vent.trigger "show:chat:sidebar"
          $('#chat-sidebar-region').attr('class', 'chats-sidebar-container')