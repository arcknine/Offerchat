@Offerchat.module "NavigationApp", (NavigationApp, App, Backbone, Marionette, $, _) ->
  
  class NavigationApp.Router extends Marionette.AppRouter
    appRoutes:
      ""        : "showNavigation"

  API =
    showNavigation: ->
      new NavigationApp.Show.Controller

  App.addInitializer ->
    new NavigationApp.Router
      controller: API