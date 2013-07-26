@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Profile extends Entities.Model
    urlRoot: Routes.profiles_path()

  API =
    getProfile: ->
      profile = new Entities.Profile
      App.request "show:preloader"
      profile.fetch
        reset: true
        success: ->
          App.request "hide:preloader"
        error: ->
          App.request "hide:preloader"
      profile

    editProfile: (id)->
      new Entities.Profile
        id: id

  App.reqres.setHandler "get:current:profile", ->
    API.getProfile()