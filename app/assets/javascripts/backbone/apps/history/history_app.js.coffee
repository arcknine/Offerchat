@Offerchat.module "HistoryApp", (HistoryApp, App, Backbone, Marionette, $, _) ->
  
  class HistoryApp.Router extends Marionette.AppRouter
    appRoutes:
      "history"            : "conversations"
    
    API =
      conversations: ->
        new HistoryApp.Conversations.Controller
          region: App.mainRegion

    App.addInitializer ->
      new HistoryApp.Router
        controller: API