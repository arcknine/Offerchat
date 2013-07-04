@Offerchat.module "SelectorApp", (SelectorApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false
  
  API =
    show: ->
      new SelectorApp.Show.Controller
        region: App.siteSelectorRegion
  
  SelectorApp.on "start", ->
    API.show()