@Offerchat.module "NavigationApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Nav extends App.Views.ItemView
    template: "navigation/show/nav"
    className: "header-wrapper-inner"
    modelEvents:
      "change"                           : "render"

    triggers:
      "click a#root-path-link"           : "root:path:clicked"
      "click li.profile-status"          : "profile:status:toggled"
      "click li.profile-settings"        : "profile:settings:toggled"
      "click li.history-menu-link"       : "history:menu:clicked"
      "click li.reports-menu-link"       : "reports:menu:clicked"
      "click a.add-more-btn"             : "upgrade:menu:clicked"
      "click a#settings-menu-link"       : "settings:menu:clicked"
      "click a#websites-menu-link"       : "websites:menu:clicked"
      "click a#account-menu-link"        : "account:menu:clicked"
      "click a#agent-menu-link"          : "agent:menu:clicked"
      "click a[data-status=logout]"      : "logout"

    events:
      "click a[data-status=logout]" : "logout"
      "click a#changeStatus"        : "changeStatus"

    logout: ->
      location.href = Routes.destroy_user_session_path()

    changeStatus: (e) ->
      @trigger "change:user:status", e