@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Site extends App.Entities.Model
    urlRoot: Routes.websites_path()

  class Entities.SiteTriggers extends App.Entities.Model
    urlRoot: "/triggers"

  class Entities.WebsiteTriggers extends App.Entities.Collection
    model: Entities.SiteTriggers

  class Entities.SiteCollection extends App.Entities.Collection
    model: Entities.Site
    url:   Routes.websites_path()

  API =
    newSites: ->
      new Entities.SiteCollection

    getSites: ->
      site = new Entities.SiteCollection
      site.fetch
        reset: true
      site

    getManageSites: ->
      sites = new Entities.SiteCollection
      sites.url = Routes.managed_websites_path()
      sites.fetch
        reset: true
        success: ->
          sites.url = Routes.websites_path()
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

    getWebsiteTriggers: (website_id) ->
      triggers = new Entities.WebsiteTriggers
      triggers.url = Routes.triggers_website_path website_id
      triggers.fetch
        reset: true
      triggers

  App.reqres.setHandler "site:entities", ->
    API.getSites()

  App.reqres.setHandler "new:site:entities", ->
    API.newSites()

  App.reqres.setHandler "site:new:entity", ->
    API.newSite()

  App.reqres.setHandler "get:website:triggers", (website_id) ->
    API.getWebsiteTriggers website_id

  App.reqres.setHandler "manage:sites:entities", ->
    API.getManageSites()
