@Offerchat.module "SidebarApp", (SidebarApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false
  
  API =
    showSelector: ->
      console.log 1
      new SidebarApp.Selector.Controller
        region: App.selectorSidebarRegion

    showVisitors: ->
      new SidebarApp.Visitors.Controller
        region: App.chatSidebarRegion

  
  SidebarApp.on "start", ->
    API.showSelector()
    #API.showVisitors()