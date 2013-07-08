@Offerchat.module "AccountsApp", (AccountsApp, App, Backbone, Marionette, $, _) ->
  
  class AccountsApp.Router extends Marionette.AppRouter
    appRoutes:
      "profiles"        :         "show"
      "profiles/passwords" :      "editPassword"
      #"profiles/notifications" :  "editNotifications"
      #"profiles/agents" :         "listAgents"
      #"profiles/websites" :       "listWebsites"
      #"profiles/invoices" :       "listInvoices"
      
    API = 
      show: ->
        new AccountsApp.Show.Controller
          section: "profiles"
        
      editPassword: ->
        new AccountsApp.Show.Controller
          section: "password"
        
      #editNotifications: ->
      #  new AccountsApp.Notifications.Controller
      #  
      #listAgents: ->
      #  new AccountsApp.Agent.Controller
      #  
      #listWebsites: ->
      #  new AccountsApp.Website.Controller
      #  
      #listInvoices: ->
      #  new AccountsApp.Invoice.Controller
        
    
    App.addInitializer ->
      new AccountsApp.Router
        controller: API