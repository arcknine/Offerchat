@Offerchat.module "ProfileApp", (ProfileApp, App, Backbone, Marionette, $, _) ->

  class ProfileApp.Router extends Marionette.AppRouter
    appRoutes:
      "profile" : "showProfile"

  API =
    showProfile: ->
      ProfileApp.Show.Controller.showProfile()

    listUsers: ->
      UsersApp.List.Controller.listUsers()

  App.addInitializer ->
    new ProfileApp.Router
      controller: API