@Offerchat.module "AccountsApp.Instructions", (Instructions, App, Backbone, Marionette, $, _) ->
  
  class Instructions.Controller extends App.Controllers.Base
    
    initialize: (options) ->
      profile = App.request "get:current:profile"
      App.execute "when:fetched", profile, =>
        @layout = @getLayoutView(profile)
        @listenTo @layout, "show", =>
          @sidebarRegion()
        @show @layout
    
    sidebarRegion: ->
      navView = @getSidebarNavs()
    
      @listenTo navView, "nav:accounts:clicked", (item) =>
        App.navigate Routes.profiles_path(), trigger: true
    
      @listenTo navView, "nav:password:clicked", (item) =>
        App.navigate '#profiles/passwords', trigger: true
    
      @listenTo navView, "nav:invoices:clicked", (item) =>
        App.navigate '#profiles/invoices', trigger: true
        
      @listenTo navView, "nav:instructions:clicked", (item) =>
        App.navigate '#profiles/instructions', trigger: true
    
      @layout.accountSidebarRegion.show navView

    getSidebarNavs: ->
      new Instructions.Navs
    
    getLayoutView: (profile) ->
      new Instructions.Layout
        model: profile