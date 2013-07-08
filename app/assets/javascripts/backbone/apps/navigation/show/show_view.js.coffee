@Offerchat.module "NavigationApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Nav extends App.Views.ItemView
    template: "navigation/show/nav"
    #className: "header-wrapper"
    
    triggers:
      "click .profile-status a"                   : "profile:status:toggled"
      "click .profile-settings.header-settings a" : "profile:settings:toggled"
      "click a#account-menu-link"                 : "account:menu:clicked"
      "click a#chat-history-menu-link"            : "chat:history:menu:clicked"
      "click a#history-menu-link"                 : "history:menu:clicked"
      "click a#agent-menu-link"                   : "agent:menu:clicked"
      "click a#knowlegdebase-menu-link"           : "knowlegdebase:menu:clicked"
      "click a#integrations-menu-link"            : "integrations:menu:clicked"
      "click a#labs-menu-link"                    : "labs:menu:clicked"