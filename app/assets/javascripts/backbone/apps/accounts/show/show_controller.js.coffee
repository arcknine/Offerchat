@Offerchat.module "AccountsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    
    initialize: (options)->
      console.log options
      @account = App.request "get:current:profile"
      App.execute "when:fetched", @account, =>
        @layout = @getLayoutView()
        
        @listenTo @layout, "show", =>
          @sidebarRegion(options.section)
          @getMainRegion(options.section)
          @setSelectedNav(options.section)

        @show @layout
      
    sidebarRegion: (section)->
      navView = @getSidebarNavs()
      #@setSelectedNav(navView, section)
      
      @listenTo navView, "nav:accounts:clicked", (item) =>
        App.navigate Routes.profiles_path(), trigger: true
        
      @listenTo navView, "nav:password:clicked", (item) =>
        App.navigate '#profiles/passwords', trigger: true
        
      @listenTo navView, "notifications", (item) =>
        App.navigate '#profiles/notifications', trigger: true
        alert 3
        
      @listenTo navView, "agents", (item) =>
        App.navigate '#profiles/agents', trigger: true
        alert 4
        
      @listenTo navView, "websites", (item) =>
        App.navigate '#profiles/websites', trigger: true
        alert 5
        
      @listenTo navView, "invoices", (item) =>
        App.navigate '#profiles/invoices', trigger: true
        alert 6
      
      @layout.accountSidebarRegion.show navView

    getMainRegion: (section) ->
      if section is "profiles"
        @getProfileRegion(@account)
      else if section is "password"
        @getPasswordRegion(@account)
  
    getProfileRegion: ->
      profileView = @getProfileView(@account)
      @layout.accountRegion.show profileView
    
    getPasswordRegion: ->
      passwordView = @getPasswordView(@account)
      @layout.accountRegion.show passwordView
      
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
      
    setSelectedNav: (item, section) ->
      $(item.el).find("ul li a").addClass("selected")
      $(item.el).find("ul li a").removeClass("selected")
      if section is "profile"
        $(item.el).find("ul li a.profile").addClass("selected")
      if section is "password"
        $(item.el).find("ul li a.password").addClass("selected")