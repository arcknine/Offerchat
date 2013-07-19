@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Trigger extends App.Entities.Model
    urlRoot: "/triggers"

  class Entities.TriggersCollection extends App.Entities.Collection
    model: Entities.Trigger
    url: "/triggers/this_website/1" # route to get website triggers

  API =
    newTrigger: ->
      new Entities.Trigger

    tempTriggers: ->
      new Backbone.Collection [
        { time: 30, loc: "Any page", msg: "You have spent 30 seconds on the site", rule: 1 }
        { time: 10, loc: "http://homeurl.com", msg: "Hi, how can we help you", rule: 2 }
        { time: 5, loc: "http://homeurl.com/about", msg: "This is the about us page", rule: 3 }
      ]

  App.reqres.setHandler "new:trigger", ->
    API.newTrigger()