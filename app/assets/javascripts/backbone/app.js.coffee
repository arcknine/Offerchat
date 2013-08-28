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

  App.reqres.setHandler "get:current:user", ->
    App.request "set:current:user", App.request "get:current:user:json"

  App.reqres.setHandler "csrf-token", ->
    $("meta[name='csrf-token']").attr('content')

  App.reqres.setHandler "default:region", ->
    App.mainRegion

  App.on "initialize:after", ->
    @startHistory()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

  # event can be found in 'config/marionette/application.js.coffee'
  # event will execute every change of url
  Backbone.on 'execute:route:change:events', ->
    App.execute "set:no:active:chat"

  App