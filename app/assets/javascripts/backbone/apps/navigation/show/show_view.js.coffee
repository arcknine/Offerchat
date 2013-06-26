@Offerchat.module "NavigationApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Nav extends App.Views.ItemView
    template: "navigation/show/nav"