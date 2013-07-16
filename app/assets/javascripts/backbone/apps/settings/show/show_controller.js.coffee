@Offerchat.module "SettingsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options) ->
      @layout = @getLayoutView()
      sites = App.request "my:sites:entities"

      App.execute "when:fetched", sites, =>
        @currentSite = sites.first()

        @listenTo @layout, "show", =>
          @sitesView sites

        @listenTo @layout, "navigate:settings", (section) =>
          console.log section

        @show @layout

    sitesView: (sites) ->
      sitesView = @getSitesView sites
      @layout.sitesRegion.show sitesView

    getLayoutView: ->
      new Show.Layout

    getStyleView: (website) ->
      new Show.Style
        model: website

    getSitesView: (sites) ->
      new Show.Sites
        collection: sites
        currentSite: @currentSite

    setSelectedNav: (nav, section) ->
      $(nav.el).find("ul li a." + section).addClass('selected')

    showView: (view)->
      @show view
