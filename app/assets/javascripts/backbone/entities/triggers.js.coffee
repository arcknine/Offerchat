@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Trigger extends App.Entities.Model
    urlRoot: "/triggers"

  class Entities.WebsiteTriggers extends App.Entities.Collection
    model: Entities.Trigger

  API =
    newTrigger: ->
      new Entities.Trigger

    getWebsiteTriggers: (website_id) ->
      triggers = new Entities.WebsiteTriggers
      triggers.url = Routes.triggers_website_path website_id
      App.request "show:preloader"
      triggers.fetch
        reset: true
        success: ->
          App.request "hide:preloader"
        error: ->
          App.request "hide:preloader"
      triggers

  App.reqres.setHandler "new:trigger", ->
    API.newTrigger()

  App.reqres.setHandler "get:website:triggers", (website_id) ->
    API.getWebsiteTriggers website_id