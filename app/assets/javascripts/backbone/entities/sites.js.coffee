@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Site extends App.Entities.Model

  class Entities.SiteCollection extends App.Entities.Collection
    model: Entities.Site
    url: "/websites"



  API =
    newSites: ->
      new Entities.SiteCollection

    getSites: ->
      site = new Entities.SiteCollection
      site.fetch
        reset: true
      site

    newSite: ->
      new Entities.Site

  App.reqres.setHandler "site:entities", ->
    API.getSites()

  App.reqres.setHandler "site:new:entity", ->
    API.newSite()

  App.reqres.setHandler "new:site:entities", ->
    API.newSites()

