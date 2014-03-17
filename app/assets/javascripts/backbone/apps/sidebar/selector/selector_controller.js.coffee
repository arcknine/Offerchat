@Offerchat.module "SidebarApp.Selector", (Selector, App, Backbone, Marionette, $, _) ->

  class Selector.Controller extends App.Controllers.Base

    initialize: ->
      sites        = App.request "site:entities"
      @currentSite = App.request "new:selector:site"
      @unreadMsgs  = App.request "unread:messages:entities"
      @layout      = @getLayoutView()

      @currentUser = App.request "get:current:user"

      @listenTo @layout, "all", (ev) =>
        if ev is "render" or ev is "show"
          plan = @currentUser.get("plan_identifier")

          if ["PROTRIAL", "BASIC", "AFFILIATE", "BASICYEAR", null, ""].indexOf(plan) isnt -1
            $(".new-website-link").remove()

      App.execute "when:fetched", sites, =>
        @currentSite.set { all: true, name: "All websites" }

        @bindLayoutEvents()

        @listenTo @layout, "show", ->
          @initWebsitesRegion(sites)

        @listenTo @layout, "selector:clicked", (item) ->
          @toggleSiteSelector item.view

        @listenTo @layout, "render", =>
          @initWebsitesRegion(sites)

        @show @layout

      @listenTo sites, "change", =>
        counter = 0
        unreads = sites.pluck("unread")
        $.each unreads, (key, value) =>
          counter += value

        data = { allUnread: counter, unreadClass: "" }
        data.unreadClass = "hide" if counter is 0 || counter is null

        $.each sites.models, (key, value) =>
          value.set allUnread: counter, unreadClass: ""

        @currentSite.set data

      App.reqres.setHandler "get:sidebar:selected:site", =>
        @currentSite

      App.reqres.setHandler "get:all:sites", ->
        sites

      App.reqres.setHandler "get:unread:messages", =>
        @unreadMsgs

    bindLayoutEvents: ->
      @listenTo @layout, "selector:all:websites", (item) =>
        @toggleSiteSelector item.view
        App.navigate Routes.root_path(), trigger: true unless Backbone.history.fragment.indexOf("chats") is -1

        setTimeout(=>
          @currentSite.set { all: true, name: "All websites" }
        ,100)
        # $(item.view.el).find(".site-selector > span").html("All websites")

      @listenTo @layout, "selector:new:website", (item) =>
        plan = @currentUser.get("plan_identifier")
        if ["PROTRIAL", "BASIC", "AFFILIATE", "BASICYEAR", null, ""].indexOf(plan) isnt -1
          @showNotification "You are not allowed to create new websites.", "warning"
        else
          @toggleSiteSelector item.view
          App.navigate Routes.new_website_path(), trigger: true

    getLayoutView: ->
      new Selector.Layout
        model: @currentSite

    initWebsitesRegion: (collection) ->
      websitesView = @getWebsitesView(collection)

      @listenTo websitesView, "childview:selected:website:clicked", (item) =>
        @toggleSiteSelector @layout
        item.model.attributes.unreadClass = "hide" if item.model.get("unread") is 0
        item.model.attributes.all = false

        App.navigate Routes.root_path(), trigger: true unless Backbone.history.fragment.indexOf("chats") is -1
        setTimeout(=>
          @currentSite.set item.model.attributes
        , 100)

      @layout.optionsRegion.show websitesView

    getWebsitesView: (collection)->
      new Selector.Websites
        collection: collection

    toggleSiteSelector: (view)->
      if $(view.el).hasClass("open")
        $(view.el).removeClass("open")
      else
        $(view.el).addClass("open")

    hideDropDown: ->
      $(@layout.el).find(".site-selector").removeClass("active")
      $("#site-selector-region").removeClass("open")