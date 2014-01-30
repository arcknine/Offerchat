@Offerchat.module "WebsitesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      @profile = App.request "get:current:profile"

      App.execute "when:fetched", @profile, =>
        plan = @profile.get("plan_identifier")
        if plan is null or plan is ""
          App.navigate "/", trigger: true
        else

          @manageSites   = App.request "manage:sites:entities"
          @sites         = App.request "owned:sites:entities"

          App.execute "when:fetched", @manageSites, =>
            @totalSites    = @manageSites.length + @sites.length

          sitesView = @getWebsitesView @sites

          App.mainRegion.show sitesView

          @listenTo sitesView, "click:new:website", =>
            if ["PROTRIAL", "AFFILIATE", "BASIC"].indexOf(plan) isnt -1
              alert "You need to upgrade to PRO plan to be able to add new website."
              App.navigate "upgrade", trigger: true
            else
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
      @showModalDelete site

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


    getModalDelete: (site) ->

      new List.ModalDelete
        model: site.model

    showModalDelete: (site) ->
      modalDeleteView = @getModalDelete site

      formView = App.request "modal:wrapper", modalDeleteView

      @listenTo formView, "modal:close", (item) ->
        formView.close()

      @listenTo formView, "modal:cancel", (item) ->
        formView.close()

      @listenTo formView, "modal:unsubmit", (item) ->
        formView.close()
        item.model.destroy()

        @totalSites = @totalSites - 1
        console.log "siteLeft: ", @totalSites
        if @totalSites >= 1
          App.vent.trigger "show:chat:sidebar"

        else if @totalSites is 0
          App.vent.trigger "show:wizard:sidebar"
          $('#chat-sidebar-region').attr('class', 'tour-sidebar')
          $('#siteSelector').hide()
          App.navigate "#websites/new", trigger: true

      App.modalRegion.show formView



