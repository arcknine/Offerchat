@Offerchat = do (Backbone, Marionette) ->

  App = new Marionette.Application
  App.rootRoute = "school"
  App.version = "v1"
  
  App.addRegions
    navigationRegion: "#navigation-region"
    sidebarRegion:    "#sidebar-region"
    mainRegion:       "#main-region"

  App.addInitializer ->
    App.module("NavigationApp").start()
    
  App.reqres.setHandler "get:current:user", ->
    App.currentUser
  
  App.reqres.setHandler "csrf-token", ->
    $("meta[name='csrf-token']").attr('content')
    
  App.reqres.setHandler "default:region", ->
    App.mainRegion

  App.on "initialize:after", ->
    if Backbone.history
      Backbone.history.start()
      @navigate(@rootRoute, trigger: true) if @getCurrentRoute() is ""

  App