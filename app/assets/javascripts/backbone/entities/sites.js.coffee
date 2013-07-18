@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Site extends App.Entities.Model
    # urlRoot: Routes.websites_path()
  class Entities.NewSite extends App.Entities.Model
    # defaults:
    #   url: sessionStorage.getItem("url") ? sessionStorage.getItem("url") : null
    #   position: sessionStorage.getItem("url") ? sessionStorage.getItem("url") : null

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
      storage = JSON.parse(sessionStorage.getItem("newSite")) || {}
      new Entities.NewSite
        url: (if not storage.url then false else storage.url)
        name: (if not storage.name then 'my website name' else storage.name)
        greeting: (if not storage.greeting then 'Hello! How can I help you today?' else storage.greeting)
        color: (if not storage.greeting then 'cadmiumreddeep' else storage.color)
        position: (if not storage.greeting then 'right' else storage.position)
        api_key: (if not storage.api_key then false else storage.api_key)

  App.reqres.setHandler "site:entities", ->
    API.getSites()

  App.reqres.setHandler "site:new:entity", ->
    API.newSite()

  App.reqres.setHandler "my:sites:entities", ->
    API.getMySites()
