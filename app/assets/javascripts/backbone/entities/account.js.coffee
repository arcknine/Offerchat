@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->
  
  class Entities.Profile extends Entities.Model
    
  API =
    getProfile: ->
      new Entities.Profile

    editProfile: (id)->
      new Entities.Profile
        id: id

  App.reqres.setHandler "get:current:profile", ->
    API.getProfile()