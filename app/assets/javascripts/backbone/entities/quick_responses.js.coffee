@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.QuickResponse extends App.Entities.Model
    urlRoot: "/quick_responses"

  class Entities.QuickResponses extends App.Entities.Collection
    model: Entities.QuickResponse

  API =
    newQR: ->
      new Entities.QuickResponse

    getQuickResponses: ->
      qrs = new Entities.QuickResponses
      qrs.url = Routes.quick_responses_path()
      qrs.fetch
        reset: true
      qrs

  App.reqres.setHandler "new:qr", ->
    API.newQR()

  App.reqres.setHandler "get:qrs", ->
    API.getQuickResponses()