@Offerchat.module "NavigationApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Nav extends App.Views.ItemView
    template: "navigation/show/nav"
    className: "header-wrapper-inner"

    triggers:
      "click a#root-path-link"           : "root:path:clicked"
      "click a#profile-status-toggle"    : "profile:status:toggled"
      "click a#settings-dropdown-toggle" : "profile:settings:toggled"
      "click a#settings-menu-link"       : "settings:menu:clicked"
      "click a#websites-menu-link"       : "websites:menu:clicked"
      "click a#account-menu-link"        : "account:menu:clicked"
      "click a#history-menu-link"        : "history:menu:clicked"
      "click a#agent-menu-link"          : "agent:menu:clicked"