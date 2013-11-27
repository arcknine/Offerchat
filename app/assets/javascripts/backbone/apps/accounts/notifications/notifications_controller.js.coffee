@Offerchat.module "AccountsApp.Notifications", (Notifications, App, Backbone, Marionette, $, _) ->

  class Notifications.Controller extends App.Controllers.Base

    initialize: (options)->
      @layout = @getLayoutView()

      @profile = App.request "get:current:profile"

      App.execute "when:fetched", @profile, =>
        @listenTo @layout, "show", =>
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
      notificationsView = @getNotificationRegions()

      @listenTo notificationsView, "show", =>
        notificationsView.desktopNotificationRegion.show @getDesktop()

        soundNotificationView = @getSound()
        @listenTo soundNotificationView, "sound:notification:toggle", (e) =>
          target = $(e.currentTarget)
          if target.hasClass("checked")
            target.removeClass("checked")
          else
            target.addClass("checked")

          parent = target.parents(".section-container")

          notif_settings =
            new_message: parent.find(".new_message").hasClass("checked")
            new_visitor: parent.find(".new_visitor").hasClass("checked")

          @profile.url = Routes.profiles_path()
          @profile.set
            update_settings: true
            notifications: notif_settings
          @profile.save {},
            success: (data) ->
              App.execute "change:user:notification", notif_settings

        notificationsView.soundNotificationRegion.show soundNotificationView

      @layout.accountRegion.show notificationsView

    getSound: =>
      new Notifications.Sound
        model: @profile

    getDesktop: ->
      havePermission = window.webkitNotifications.checkPermission()
      if localStorage.getItem("notification") is "true" and havePermission is 0 then allowed = "checked" else allowed = ""

      new Notifications.Desktop
        allowed: allowed

    getNotificationRegions: ->
      new Notifications.Regions