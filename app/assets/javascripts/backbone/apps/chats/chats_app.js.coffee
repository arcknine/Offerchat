@Offerchat.module "ChatsApp", (ChatsApp, App, Backbone, Marionette, $, _) ->

  class ChatsApp.Router extends Marionette.AppRouter
    appRoutes:
      "chats/visitor/:token" : "show"
      "chats/agent/:token"   : "agent"

    API =
      show: (token) ->
        new ChatsApp.Show.Controller
          region: App.mainRegion
          token:  token

      agent: (token) ->
        new ChatsApp.Show.Controller
          region: App.mainRegion
          token:  token

    App.addInitializer ->
      new ChatsApp.Router
        controller: API