@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Site extends App.Entities.Model
    urlRoot: "/websites"

  class Entities.SiteCollection extends App.Entities.Collection
    model: Entities.Site
    url: "/websites"

  class Entities.MySiteCollection extends App.Entities.Collection
    model: Entities.Site
    url: Routes.my_sites_websites_path()

  API =
    newSites: ->
      new Entities.SiteCollection

    getSites: ->
      site = new Entities.SiteCollection
      site.fetch
        reset: true
      site

    getMySites: ->
      site = new Entities.MySiteCollection
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

  App.reqres.setHandler "my:sites:entities", ->
    API.getMySites()