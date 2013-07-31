@Offerchat.module "ChatsApp", (ChatsApp, App, Backbone, Marionette, $, _) ->

  class ChatsApp.Router extends Marionette.AppRouter
    appRoutes:
      "chats/:token" : "show"

    API =
      show: (token) ->
        new ChatsApp.Show.Controller
          region: App.mainRegion
          token:  token

    App.addInitializer ->
      new ChatsApp.Router
        controller: API