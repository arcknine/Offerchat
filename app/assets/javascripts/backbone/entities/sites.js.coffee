@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Site extends App.Entities.Model
    urlRoot: Routes.websites_path()

  class Entities.SiteCollection extends App.Entities.Collection
    model: Entities.Site
    url:   Routes.websites_path()

  API =
    newSites: ->
      new Entities.SiteCollection

    getSites: ->
      site = new Entities.SiteCollection
      App.request "show:preloader"
      site.fetch
        reset: true
        success: ->
          App.request "hide:preloader"
        error: ->
          App.request "hide:preloader"
      site

    getOwnedSites: ->
      sites = new Entities.SiteCollection
      sites.url = Routes.owned_websites_path()
      App.request "show:preloader"
      sites.fetch
        reset: true
        success: ->
          sites.url = Routes.websites_path()
          App.request "hide:preloader"
        error: ->
          App.request "hide:preloader"
      sites

    getManageSites: ->
      sites = new Entities.SiteCollection
      sites.url = Routes.managed_websites_path()
      App.request "show:preloader"
      sites.fetch
        reset: true
        success: ->
          sites.url = Routes.websites_path()
          App.request "hide:preloader"
        error: ->
          App.request "hide:preloader"
      sites

    newSite: ->
      storage = JSON.parse(sessionStorage.getItem("newSite")) || {}
      new Entities.Site
        url:      (if not storage.url then false else storage.url)
        name:     (if not storage.name then 'my website name' else storage.name)
        greeting: (if not storage.greeting then 'Hello! How can I help you today?' else storage.greeting)
        color:    (if not storage.color then 'cadmiumreddeep' else storage.color)
        position: (if not storage.position then 'right' else storage.position)
        gradient: (if not storage.gradient then false else storage.gradient)
        rounded:  (if not storage.rounded then true else storage.rounded)
        api_key:  (if not storage.api_key then false else storage.api_key)

  App.reqres.setHandler "site:entities", ->
    API.getSites()

  App.reqres.setHandler "new:site:entities", ->
    API.newSites()

  App.reqres.setHandler "site:new:entity", ->
    API.newSite()

  App.reqres.setHandler "new:site:entity", ->
    API.newSite()

  App.reqres.setHandler "manage:sites:entities", ->
    API.getManageSites()

  App.reqres.setHandler "owned:sites:entities", ->
    API.getOwnedSites()
