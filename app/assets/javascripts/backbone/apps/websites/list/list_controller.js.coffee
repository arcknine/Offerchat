@Offerchat.module "WebsitesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->

      @sites     = App.request "manage:sites:entities"
      @sites     = App.request "owned:sites:entities"

      sitesView = @getWebsitesView @sites

      App.mainRegion.show sitesView


      @listenTo sitesView, "click:new:website", =>
         App.navigate Routes.new_website_path(), trigger: true

      @listenTo sitesView, "childview:click:delete:website", @deleteSite


      @listenTo sitesView, "childview:click:edit:website", @showModal


    getWebsitesView: (sites) ->
      new List.Websites
        collection: sites

    getEditWebsiteModalView: (site) ->
      new List.ModalWebsite
        model: site.model

    deleteSite: (site) ->
      if confirm("Are you sure you want to delete this website?")
        site.model.destroy()
        if @sites.length isnt 1 and @sites.length isnt 0
          App.vent.trigger "show:chat:sidebar"
        else
          App.vent.trigger "show:wizard:sidebar"
          $('#chat-sidebar-region').attr('class', 'tour-sidebar')
          $('#siteSelector').hide()
          App.navigate "#websites/new", trigger: true

    showModal: (site) ->

      modalView = @getEditWebsiteModalView site

      @listenTo site.model, "updated", (site) =>
        @showNotification("Your changes have been saved")
        formView.trigger "modal:close"

      formView  = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:close", (item)->
        formView.close()

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      # console.log "formView", formView

      App.modalRegion.show formView
