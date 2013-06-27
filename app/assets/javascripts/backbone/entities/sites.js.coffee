@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->
  
  class Entities.Site extends App.Entities.Model
    urlRoot: "/websites"

  class Entities.SiteCollection extends App.Entities.Collection
    model: Entities.Site
    url: "/websites"
    
  API =
    getSites: ->
      site = new Entities.SiteCollection
      site .fetch
        reset: true
      site 
      
  App.reqres.setHandler "site:entities", ->
    API.getSites()