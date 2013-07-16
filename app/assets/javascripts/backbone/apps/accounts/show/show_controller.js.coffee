@Offerchat.module "AccountsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options)->

      profile = App.request "get:current:profile"

      App.execute "when:fetched", profile, =>
        @layout = @getLayoutView()

        @listenTo @layout, "show", =>
          @sidebarRegion(options.section)
          @getMainRegion(profile, options.section)

        @show @layout

    sidebarRegion: (section)->
      navView = @getSidebarNavs()

      @listenTo navView, "nav:accounts:clicked", (item) =>
        App.navigate Routes.profiles_path(), trigger: true

      @listenTo navView, "nav:password:clicked", (item) =>
        App.navigate '#profiles/passwords', trigger: true

      @layout.accountSidebarRegion.show navView
      @setSelectedNav(navView, section)

    getMainRegion: (profile, section) ->
      if section is "profile"
        @getProfileRegion(profile)
      else if section is "password"
        @getPasswordRegion(profile)

    getProfileRegion: (profile)->
      profileView = @getProfileView(profile)

      @listenTo profileView, "change:photo:clicked", (item) =>
        params =
          element: item
          openClass: "btn-selector"
          activeClass: "btn-action-selector"

        profileView.toggleDropDown params

        # App.request "toggle:dropdown", params

      @listenTo profileView, "upload:button:change", (item) =>
        # # App.request "close:dropdowns"
        console.log "clicked"

        params =
          element: item
          openClass: "btn-selector"
          activeClass: "btn-action-selector"

        profileView.toggleDropDown params
        # true

      @listenTo profileView, "upload:button:blur", (item) =>
        # # App.request "close:dropdowns"
        console.log "blur"

      formView = App.request "form:wrapper", profileView
      profile.url = Routes.profiles_path()
      @layout.accountRegion.show formView

    getPasswordRegion: (profile)->
      passwordView = @getPasswordView(profile)
      formView = App.request "form:wrapper", passwordView
      profile.url = Routes.passwords_path()
      @layout.accountRegion.show formView

    getPasswordView: (model)->
     new Show.Password
       model: model

    getProfileView: (model)->
      new Show.Profile
        model: model

    getSidebarNavs: ->
      new Show.Navs

    getLayoutView: ->
      new Show.Layout

    setSelectedNav: (nav, section) ->
      $(nav.el).find("ul li a." + section).addClass('selected')