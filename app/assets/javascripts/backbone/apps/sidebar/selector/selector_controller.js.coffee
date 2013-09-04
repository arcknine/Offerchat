@Offerchat.module "SidebarApp.Selector", (Selector, App, Backbone, Marionette, $, _) ->

  class Selector.Controller extends App.Controllers.Base

    initialize: ->
      sites        = App.request "site:entities"
      @currentSite = App.request "new:selector:site"
      @readMsgs    = App.request "total:unread:messages"

      App.execute "when:fetched", sites, =>
        site = sites.last()
        site.attributes.all = false;

        @currentSite.set site.attributes

        @layout = @getLayoutView()
        @bindLayoutEvents()

        @listenTo @layout, "show", ->
          @initSiteSelectorRegion(site)
          @initWebsitesRegion(sites)

        @listenTo @layout, "selector:clicked", (item) ->
          @toggleSiteSelector item.view

        @show @layout

      App.reqres.setHandler "get:sidebar:selected:site", =>
        @currentSite

      App.reqres.setHandler "get:all:sites", ->
        sites

      App.reqres.setHandler "get:total:unread:messages", =>
        @readMsgs

    bindLayoutEvents: ->
      @listenTo @layout, "selector:all:websites", =>
        @hideDropDown()
        $(@layout.el).find(".site-selector > div > span").html("All websites")

        @currentSite.set { all: true }

      @listenTo @layout, "selector:new:website", ->
        @hideDropDown()
        App.navigate Routes.new_website_path(), trigger: true

    getLayoutView: ->
      new Selector.Layout

    initSiteSelectorRegion: (model)->
      selectedSiteView = @getSiteSelectorView(model)

      @layout.selectedSiteRegion.show selectedSiteView

    getSiteSelectorView: (model) ->
      new Selector.SiteSelector
        model: model

    initWebsitesRegion: (collection) ->
      websitesView = @getWebsitesView(collection)

      @listenTo websitesView, "childview:selected:website:clicked", (item) =>
        @hideDropDown()

        item.model.attributes.all = false;
        @currentSite.set item.model.attributes

        @initSiteSelectorRegion item.model

      @layout.optionsRegion.show websitesView

    getWebsitesView: (collection)->
      new Selector.Websites
        collection: collection

    toggleSiteSelector: (view)->
      if $(view.el).find("#siteSelector").hasClass("active")
        $(view.el).find("#siteSelector").removeClass("active")
        $(@region.currentView.el).parent().removeClass("open")
      else
        $(view.el).find("#siteSelector").addClass("active")
        $(@region.currentView.el).parent().addClass("open")

    hideDropDown: ->
      $(@layout.el).find(".site-selector").removeClass("active")
      $("#site-selector-region").removeClass("open")



