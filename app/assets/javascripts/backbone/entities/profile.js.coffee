@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Profile extends Entities.Model
    urlRoot: Routes.profiles_path()

  API =
    getProfile: ->
      profile = new Entities.Profile
      profile.fetch
        reset: true
      profile

    editProfile: (id)->
      new Entities.Profile
        id: id

  App.reqres.setHandler "get:current:profile", ->
    API.getProfile()