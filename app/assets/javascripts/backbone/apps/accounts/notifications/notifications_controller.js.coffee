@Offerchat.module "AccountsApp.Notifications", (Notifications, App, Backbone, Marionette, $, _) ->

  class Notifications.Controller extends App.Controllers.Base

    initialize: (options)->
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        console.log 'layout shown'
        @sidebarRegion()
        @getNotificationsRegion()

      @show @layout


    getLayoutView: ->
      new Notifications.Layout

    sidebarRegion: ->
      navView = @getSidebarNavs()

      @listenTo navView, "nav:accounts:clicked", (item) =>
        App.navigate Routes.profiles_path(), trigger: true

      @listenTo navView, "nav:password:clicked", (item) =>
        App.navigate '#profiles/passwords', trigger: true

      @listenTo navView, "nav:notifications:clicked", (item) =>
        App.navigate '#profiles/notifications', trigger: true

      @listenTo navView, "nav:invoices:clicked", (item) =>
        App.navigate '#profiles/invoices', trigger: true

      @listenTo navView, "nav:instructions:clicked", (item) =>
        App.navigate '#profiles/instructions', trigger: true

      @layout.accountSidebarRegion.show navView

    getSidebarNavs: ->
      new Notifications.Navs

    getNotificationsRegion: ->
      notificationsView = @getNotificationsView()
      @layout.accountRegion.show notificationsView

    getNotificationsView: ->
      if localStorage.getItem("notification") is "true" then allowed = "checked" else allowed = ""
      new Notifications.View
        allowed: allowed
