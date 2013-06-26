@Offerchat.module "NavigationApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Controller extends App.Controllers.Base
    
    initialize: ->
      user_json = App.request "get:current:user:json"
      user = App.request "set:current:user", user_json

      navView = @getNavView user
      console.log App.navigationRegion
      App.navigationRegion.show navView
      
    getNavView: (user)->
      new Show.Nav
        model: user