@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.AttentionGrabber extends App.Entities.Model
    urlRoot: "/attention_grabbers"

  class Entities.AttentionGrabbers extends App.Entities.Collection
    model: Entities.AttentionGrabber

  API =
    getAttentionGrabbers: ->
      grabbers = new Entities.AttentionGrabbers
      grabbers.url = Routes.attention_grabbers_path()
      grabbers.fetch
        reset: true
      grabbers

  App.reqres.setHandler "get:default:attention:grabbers", ->
    API.getAttentionGrabbers()