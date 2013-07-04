@Offerchat = do (Backbone, Marionette) ->

  App = new Marionette.Application
  
  console.log Routes
  
  App.on "initialize:before", (options) ->
    App.currentUser = options.currentUser
  
  App.addRegions
    navigationRegion:     "#header-region"
    siteSelectorRegion:   "#site-selector-region"
    chatSidebarRegion:    "#chat-sidebar-region"
    mainRegion:           "#main-region"

  App.addInitializer ->
    App.module("NavigationApp").start()
    App.module("SelectorApp").start()
    
  App.reqres.setHandler "get:current:user:json", ->
    $.parseJSON App.currentUser
  
  App.reqres.setHandler "csrf-token", ->
    $("meta[name='csrf-token']").attr('content')
    
  App.reqres.setHandler "default:region", ->
    App.mainRegion
    
  App.on "initialize:after", ->
    @startHistory()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

  App