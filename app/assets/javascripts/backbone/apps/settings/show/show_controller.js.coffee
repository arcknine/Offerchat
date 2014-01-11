@Offerchat.module "SettingsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      { id, @section, @subForm } = options

      @profile = App.request "get:current:profile"

      sites    = App.request "manage:sites:entities"
      @layout  = @getLayoutView()

      unless App.myWebsites
        App.execute "when:fetched", sites, =>
          @loadShow sites, id
      else
        @loadShow sites, id

    loadShow: (sites, id) =>

      plan = @profile.get("plan_identifier")
      if plan is null or plan is ""
        App.navigate "/", trigger: true
      else

        @currentSite = sites.get(id) or sites.first()

        App.navigate "settings/style/#{@currentSite.get("id")}", trigger: true unless id

        @listenTo @layout, "show", =>
          @sitesView sites, id

        @show @layout

        @listenTo @layout, "navigate:settings", (section) =>
          App.navigate "settings/#{section}/#{@currentSite.get('id')}", trigger: true

        $(@layout.el).find("a[data-section='#{@section}']").addClass("selected")


    sitesView: (sites, id) ->
      sitesView = @getSitesView sites

      @listenTo sitesView, "dropdown:sites", @dropdownSites

      @listenTo sitesView, "childview:set:current:website", (child) =>
        @currentSite = child.model
        subForm      = (if @subForm and @subForm != "prechat" then "/#{@subForm}" else "")
        App.navigate "settings/#{@section}/#{@currentSite.get('id')}#{subForm}", trigger: true

      @layout.sitesRegion.show sitesView

    getLayoutView: ->
      new Show.Layout
        section: @section

    getStyleView: (website) ->
      new Show.Style
        model: website

    getSitesView: (sites) ->
      new Show.Sites
        collection: sites
        currentSite: @currentSite

    dropdownSites: (e) ->
      if $(e.currentTarget).find(".btn-selector").hasClass("open")
        $(e.currentTarget).find(".btn-selector").removeClass("open")
        $(e.currentTarget).find(".btn-action-selector.site-selector").removeClass("active")
      else
        $(e.currentTarget).find(".btn-selector").addClass("open")
        $(e.currentTarget).find(".btn-action-selector.site-selector").addClass("active")

    setSelectedNav: (nav, section) ->
      $(nav.el).find("ul li a." + section).addClass('selected')
