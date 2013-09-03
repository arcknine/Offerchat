@Offerchat.module "WebsitesApp.Key", (Key, App, Backbone, Marionette, $, _) ->

  class Key.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      sites = App.request "get:all:sites"

      @newWebsite = App.request "new:site:entity"
      newSiteView = @getWebsiteKeyView @newWebsite
      App.mainRegion.show newSiteView

      @initKeyView sites

      @listenTo newSiteView, "click:finish:website", (item) ->
        App.vent.trigger "show:chat:sidebar"
        $('#chat-sidebar-region').attr('class', 'chats-sidebar-container')
        App.navigate "#", trigger: true
        App.request "new:site:created"

      @listenTo newSiteView, "click:send:code", (item) =>
        @showModal @newWebsite

    getWebsiteKeyView: (site) ->
      new Key.Code
        model: site

    getModalView: (site) ->
      site.url = Routes.webmaster_code_websites_path
      new Key.Modal
        model: site

    showModal: (site) ->
      modalView = @getModalView site
      formView  = App.request "modal:wrapper", modalView

      @listenTo site, "created", (model) =>
        # show notification that the email was sent!!!!
        @showNotification("Website integration code has been sent!")
        formView.close()

      @listenTo formView, "modal:close", (item)->
        formView.close()

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      App.modalRegion.show formView

    initKeyView: (sites) ->
      if sites.length > 0
        App.vent.trigger "show:chat:sidebar"
        $('#chat-sidebar-region').attr('class', 'chats-sidebar-container')
      $('.opacity').remove()
      if sites.length is 0
        $('#install-checklist').addClass('checked')
        $('#install-checklist').find('span').hide()
        $('#third-check').show()
