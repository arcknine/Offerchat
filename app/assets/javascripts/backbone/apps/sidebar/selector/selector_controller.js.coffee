@Offerchat.module "SidebarApp.Selector", (Selector, App, Backbone, Marionette, $, _) ->

  class Selector.Controller extends App.Controllers.Base

    initialize: ->
      sites = App.request "site:entities"

      App.execute "when:fetched", sites, =>
        site = sites.first()
        @layout = @getLayoutView()

        @listenTo @layout, "show", ->
          @initSiteSelectorRegion(site)
          @initWebsitesRegion(sites)

        @show @layout

    getLayoutView: ->
      new Selector.Layout

    initSiteSelectorRegion: (model)->
      selectedSiteView = @getSiteSelectorView(model)

      @listenTo selectedSiteView, "selector:clicked", (item)->
        @toggleSiteSelector item.view

      @layout.selectedSiteRegion.show selectedSiteView

    getSiteSelectorView: (model)->
      new Selector.SiteSelector
        model: model

    initWebsitesRegion: (collection) ->
      websitesView = @getWebsitesView(collection)
      @listenTo websitesView, "childview:selected:website:clicked", (item) ->
        console.log item

      @layout.optionsRegion.show websitesView

    getWebsitesView: (collection)->
      new Selector.Websites
        collection: collection

    toggleSiteSelector: (view)->
      if $(view.el).parent().hasClass("active")
        $(view.el).parent().removeClass("active")
        $(@region.currentView.el).parent().removeClass("open")
      else
        $(view.el).parent().addClass("active")
        $(@region.currentView.el).parent().addClass("open")