@Offerchat.module "AccountsApp", (AccountsApp, App, Backbone, Marionette, $, _) ->
  
  class AccountsApp.Router extends Marionette.AppRouter
    appRoutes:
      "profiles"        : "show"
      
    API = 
      show: ->
        new AccountsApp.Show.Controller
    
    App.addInitializer ->
      new AccountsApp.Router
        controller: API