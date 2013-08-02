@Offerchat.module "AccountsApp", (AccountsApp, App, Backbone, Marionette, $, _) ->

  class AccountsApp.Router extends Marionette.AppRouter
    appRoutes:
      "profiles"                :   "profile"
      "profiles/passwords"      :   "editPassword"
      #"profiles/notifications"  :   "editNotifications"
      #"profiles/invoices"       :   "listInvoices"

    API =
      profile: ->
        new AccountsApp.Profile.Controller
          section: 'profile'
        
      editPassword: ->
        new AccountsApp.Password.Controller
          section: 'password'

      #editPassword: ->
      #  new AccountsApp.Password.Controller
      #    section: "password"
      #
      #editNotifications: ->
      #  new AccountsApp.Show.Controller
      #    section: 'notifications'
      #
      #listInvoices: ->
      #  new AccountsApp.Show.Controller
      #    section: 'invoices'


    App.addInitializer ->
      new AccountsApp.Router
        controller: API