@Offerchat.module "SidebarApp", (SidebarApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false
  
  API =
    show: ->
      new SidebarApp.List.Controller
        region: App.sidebarRegion
  
  SidebarApp.on "start", ->
    API.show()