@Offerchat.module "NavigationApp", (NavigationApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false
  
  API =
    show: ->
      new NavigationApp.Show.Controller
        region: App.navigationRegion
  
  NavigationApp.on "start", ->
    API.show()