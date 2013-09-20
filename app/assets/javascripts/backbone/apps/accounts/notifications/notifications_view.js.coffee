@Offerchat.module "AccountsApp.Notifications", (Notifications, App, Backbone, Marionette, $, _) ->

  class Notifications.Layout extends App.Views.Layout
    template: "accounts/notifications/layout"
    tagName: "span"

    regions:
      accountSidebarRegion:                       "#accounts-sidebar-region"
      accountRegion:                              "#accounts-main-region"

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
      console.log 'ee: ', e

      window.webkitNotifications.requestPermission(->
        havePermission = window.webkitNotifications.checkPermission()

        curr = $(e.currentTarget)
        if havePermission is 0
          curr.addClass("checked")
        else
          curr.removeClass("checked")
      )
