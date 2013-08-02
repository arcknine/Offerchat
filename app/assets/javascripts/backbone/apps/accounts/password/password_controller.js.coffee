@Offerchat.module "AccountsApp.Password", (Password, App, Backbone, Marionette, $, _) ->

  class Password.Controller extends App.Controllers.Base
    
    initialize: (options)->

      profile = App.request "get:current:profile"
    
      @listenTo profile, "updated", (item) ->
        @showNotification "Your changes have been saved!"

      App.execute "when:fetched", profile, =>
        @layout = @getLayoutView()

        @listenTo @layout, "show", =>
          @sidebarRegion(options.section)
          @getPasswordRegion(profile)

        @show @layout

    sidebarRegion: (section)->
      navView = @getSidebarNavs()

      @listenTo navView, "nav:accounts:clicked", (item) =>
        App.navigate Routes.profiles_path(), trigger: true

      @listenTo navView, "nav:password:clicked", (item) =>
        App.navigate '#profiles/passwords', trigger: true

      @layout.accountSidebarRegion.show navView

    getPasswordRegion: (profile)->
      passwordView = @getPasswordView(profile)
      formView = App.request "form:wrapper", passwordView
      profile.url = Routes.passwords_path()
      @layout.accountRegion.show formView
  
    getPasswordView: (model)->
     new Password.View
       model: model

    getSidebarNavs: ->
      new Password.Navs

    getLayoutView: ->
      new Password.Layout
