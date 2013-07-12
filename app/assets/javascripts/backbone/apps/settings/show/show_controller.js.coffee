@Offerchat.module "SettingsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options) ->
      @layout = @getLayoutView()

      @websites = App.request "site:entities"

      App.execute "when:fetched", @websites, =>

        @listenTo @layout, "show", =>
          @getSidebarRegion(options.section)
          @getMainRegion(options.section)

        @show @layout

    getSidebarRegion: (section) ->
      navView = @getSidebarNav()

      @listenTo navView, "nav:language:clicked", (item) =>
        App.navigate '#settings/language', trigger: true

      @listenTo navView, "nav:style:clicked", (item) =>
        App.navigate '#settings/style', trigger: true

      @layout.settingsSidebarRegion.show navView
      @setSelectedNav(navView, section)

    getMainRegion: (section) ->
      if section is "langauge"
        @getLanguageRegion()
      else if section is "style-and-color"
        @getStyleRegion()

    getLanguageRegion: ->
      languageView = @getLanguageView
      formView = App.request "form:wrapper", languageView
      @layout.settingsRegion.show formView

    getStyleRegion: ->
      styleView = @getStyleView(@websites.first())

      @listenTo styleView, "style:color:clicked", (element) =>
        $("#controlColorContent a").removeClass("active")
        $(element.currentTarget).addClass("active")

      formView = App.request "form:wrapper", styleView
      @layout.settingsRegion.show formView

    getSidebarNav: ->
      new Show.Nav

    getLayoutView: ->
      new Show.Layout

    getStyleView: (website) ->
      new Show.Style
        model: website

    setSelectedNav: (nav, section) ->
      $(nav.el).find("ul li a." + section).addClass('selected')