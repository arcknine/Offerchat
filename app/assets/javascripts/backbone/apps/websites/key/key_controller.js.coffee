@Offerchat.module "WebsitesApp.Key", (Key, App, Backbone, Marionette, $, _) ->

  class Key.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      sites = App.request "get:sites:count"

      newWebsite = App.request "new:site:entity"
      newSiteView = @getWebsiteKeyView newWebsite
      App.mainRegion.show newSiteView

      @initKeyView sites

      @listenTo newSiteView, "click:finish:website", (item) ->
        App.vent.trigger "show:chat:sidebar"
        $('#chat-sidebar-region').attr('class', 'chats-sidebar-container')
        App.navigate "websites", trigger: true

      @listenTo newSiteView, "click:send:code", (item) ->
        console.log 'na click ang send code sa webmaster'

    getWebsiteKeyView: (site) ->
      new Key.Code
        model: site

    initKeyView: (sites) ->
      if sites.length is 0
        $('#install-checklist').addClass('checked')
        $('#install-checklist').find('span').hide()
        $('#third-check').show()