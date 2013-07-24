@Offerchat = do (Backbone, Marionette) ->

  App = new Marionette.Application

  console.log Routes

  App.on "initialize:before", (options) ->
    App.currentUser = options.currentUser

  App.addRegions
    navigationRegion:       "#header-region"
    selectorSidebarRegion:  "#site-selector-region"
    chatSidebarRegion:      "#chat-sidebar-region"
    tourSidebarRegion:      "#tour-sidebar-region"
    mainRegion:             "#main-region"
    modalRegion:            "#modal-region"
    previewRegion:          ModalRegion

  App.addInitializer ->
    App.module("NavigationApp").start()
    App.module("SidebarApp").start()

  App.reqres.setHandler "get:current:user:json", ->
    $.parseJSON App.currentUser

  App.reqres.setHandler "csrf-token", ->
    $("meta[name='csrf-token']").attr('content')

  App.reqres.setHandler "default:region", ->
    App.mainRegion

  App.reqres.setHandler "init:preloader", (type = 'show') ->
    if type is "show" && typeof $("#canvasLoader").html() is "undefined"
      cl = new CanvasLoader("canvasloader")
      cl.setColor "#ebebeb" # default is '#000000'
      cl.setDiameter 19 # default is 40
      cl.setRange 0.8 # default is 1.3
      cl.setFPS 30 # default is 24
      cl.show() # Hidden by default

      # This bit is only for positioning - not necessary
      loaderObj = document.getElementById("canvasLoader")
      loaderObj.style.position = "absolute"
    else if type is "hide"
      $("#canvasLoader").remove()

  App.on "initialize:after", ->
    @startHistory()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

  App