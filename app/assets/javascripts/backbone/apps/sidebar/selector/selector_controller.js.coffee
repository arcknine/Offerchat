@Offerchat.module "SidebarApp.Selector", (Selector, App, Backbone, Marionette, $, _) ->

  class Selector.Controller extends App.Controllers.Base

    initialize: ->
      sites  = App.request "site:entities"

      App.execute "when:fetched", sites, =>
        site = sites.first()
        @layout = @getLayoutView()
        @bindLayoutEvents()

        App.reqres.setHandler "get:current:selector:site", ->
          site

        @listenTo @layout, "show", ->
          @initSiteSelectorRegion(site)
          @initWebsitesRegion(sites)

        @show @layout

      App.reqres.setHandler "get:sites:count", ->
        sites

    bindLayoutEvents: ->
      @listenTo @layout, "selector:all:websites", ->
        @hideDropDown()
        $(@layout.el).find(".site-selector > div > span").html("All websites")

        App.reqres.setHandler "get:current:selector:site", ->
          "all"

      @listenTo @layout, "selector:new:website", ->
        @hideDropDown()
        App.navigate Routes.new_website_path(), trigger: true

    getLayoutView: ->
      new Selector.Layout

    initSiteSelectorRegion: (model)->
      selectedSiteView = @getSiteSelectorView(model)

      @listenTo selectedSiteView, "selector:clicked", (item)->
        @toggleSiteSelector item.view

      @layout.selectedSiteRegion.show selectedSiteView

    getSiteSelectorView: (model) ->
      new Selector.SiteSelector
        model: model

    initWebsitesRegion: (collection) ->
      websitesView = @getWebsitesView(collection)

      @listenTo websitesView, "childview:selected:website:clicked", (item) ->
        @hideDropDown()

        App.reqres.setHandler "get:current:selector:site", ->
          item.model

        @initSiteSelectorRegion item.model

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

    hideDropDown: ->
      $(@layout.el).find(".site-selector").removeClass("active")
      $("#site-selector-region").removeClass("open")



