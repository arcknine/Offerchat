@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Trigger extends App.Entities.Model
    urlRoot: "/triggers"

  class Entities.TriggersCollection extends App.Entities.Collection
    model: Entities.Trigger
    url: "/triggers" # route to get user triggers

  API =
    getTriggers: ->
      triggers = new Entities.TriggersCollection
      triggers.fetch
        reset: true
      triggers

    newTrigger: ->
      new Entities.Trigger

    tempTriggers: ->
      new Backbone.Collection [
        { time: 30, loc: "Any page", msg: "You have spent 30 seconds on the site" }
        { time: 10, loc: "http://homeurl.com", msg: "Hi, how can we help you" }
        { time: 5, loc: "http://homeurl.com/about", msg: "This is the about us page" }
      ]


  App.reqres.setHandler "get:user:triggers", ->
    API.tempTriggers()

  App.reqres.setHandler "new:trigger", ->
    API.newTrigger()