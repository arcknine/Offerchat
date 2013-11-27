@Offerchat.module "AccountsApp.Notifications", (Notifications, App, Backbone, Marionette, $, _) ->

  class Notifications.Layout extends App.Views.Layout
    template: "accounts/notifications/layout"
    tagName: "span"

    regions:
      accountSidebarRegion:                       "#accounts-sidebar-region"
      accountRegion:                              "#accounts-main-region"

  class Notifications.Regions extends App.Views.Layout
    template: "accounts/notifications/notifications_layout"

    regions:
      desktopNotificationRegion:  "#desktop-notification"
      soundNotificationRegion: "#sound-notification"

  class Notifications.Sound extends App.Views.ItemView
    template: "accounts/notifications/notifications_sound"
    className: "block large group bordered-bottom"

    events:
      "click label.sound-notification"    : "toggleSound"

    toggleSound: (e) ->
      @trigger "sound:notification:toggle", e

    serializeData: ->
      notifications = @options.model.get("notifications")
      new_message: (if notifications.new_message is true then "checked" else "")
      new_visitor: (if notifications.new_visitor is true then "checked" else "")

  class Notifications.Desktop extends App.Views.ItemView
    template: "accounts/notifications/notifications_desktop"
    className: "block large group bordered-bottom"

    serializeData: ->
      allowed: @options.allowed

    events:
      "click label.desktop-notification"   : "toggleNotification"

    toggleNotification: (e) ->
      curr_elem = $(e.currentTarget)
      if curr_elem.hasClass("checked")
        localStorage.setItem("notification", false)
        curr_elem.removeClass("checked")
      else
        havePermission = window.webkitNotifications.checkPermission()
        if havePermission is 0
          curr_elem.addClass("checked")
          localStorage.setItem("notification", true)
        else
          window.webkitNotifications.requestPermission(->
            havePermission = window.webkitNotifications.checkPermission()
            if havePermission is 0
              curr_elem.addClass("checked")
              localStorage.setItem("notification", true)
            else
              curr_elem.removeClass("checked")
              localStorage.setItem("notification", false)
              alert "Please check your browser settings to allow notifications."
          )


  class Notifications.Navs extends App.Views.ItemView
    template: "accounts/notifications/sidebar"
    triggers:
      "click a" :                                 "nav:clicked"
      "click a.profile" :                         "nav:accounts:clicked"
      "click a.password" :                        "nav:password:clicked"
      "click a.notifications":                    "nav:notifications:clicked"
      "click a.invoices" :                        "nav:invoices:clicked"
      "click a.instructions" :                    "nav:instructions:clicked"

  class Notifications.View extends App.Views.ItemView
    template: "accounts/notifications/notifications"

    serializeData: ->
      allowed: @options.allowed

    events:
      "click label.desktop-notification"   : "toggleNotification"

    toggleNotification: (e) ->
      curr_elem = $(e.currentTarget)
      if curr_elem.hasClass("checked")
        localStorage.setItem("notification", false)
        curr_elem.removeClass("checked")
      else
        havePermission = window.webkitNotifications.checkPermission()
        if havePermission is 0
          curr_elem.addClass("checked")
          localStorage.setItem("notification", true)
        else
          window.webkitNotifications.requestPermission(->
            havePermission = window.webkitNotifications.checkPermission()
            if havePermission is 0
              curr_elem.addClass("checked")
              localStorage.setItem("notification", true)
            else
              curr_elem.removeClass("checked")
              localStorage.setItem("notification", false)
              alert "Please check your browser settings to allow notifications."
          )