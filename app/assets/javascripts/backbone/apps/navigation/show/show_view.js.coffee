@Offerchat.module "NavigationApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Nav extends App.Views.ItemView
    template: "navigation/show/nav"
    
    triggers:
      "click .profile-status a"                   : "profile:status:toggled"
      "click .profile-settings.header-settings a" : "profile:settings:toggled"