@Offerchat = do (Backbone, Marionette) ->

  App = new Marionette.Application

  # console.log Routes

  App.on "initialize:before", (options) ->
    App.currentUser = options.currentUser

    App.tab_active = true

    $(window).focus ->
      App.tab_active = true

    $(window).blur ->
      App.tab_active = false

    user = JSON.parse options.currentUser
    # Identify users on Mixpanel
    mixpanel.identify(user.email)
    mixpanel.people.set({
      "Name": user.name,
      "Jabber user": user.jabber_user,
      "Plan": user.plan_identifier,
      "$email": user.email
    })

  App.addRegions
    navigationRegion:       "#header-region"
    selectorSidebarRegion:  "#site-selector-region"
    chatSidebarRegion:      "#chat-sidebar-region"
    tourSidebarRegion:      "#tour-sidebar-region"
    mainRegion:             "#main-region"
    modalRegion:            "#modal-region"
    sidebarRegion:          "#sidebar-region"
    previewRegion:          ModalRegion

  App.addInitializer ->
    App.module("NavigationApp").start()
    App.module("SidebarApp").start()

  App.reqres.setHandler "is:active:tab", ->
    App.tab_active

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

    App.execute "close:quick:responses"

    if Backbone.history.fragment.indexOf("chats") is -1
      App.execute "set:no:active:chat"

    App.execute "set:original:title"

  App
