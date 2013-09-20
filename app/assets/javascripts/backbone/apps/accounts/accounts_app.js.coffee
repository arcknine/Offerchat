@Offerchat.module "AccountsApp", (AccountsApp, App, Backbone, Marionette, $, _) ->

  class AccountsApp.Router extends Marionette.AppRouter
    appRoutes:
      "profiles"                :   "profile"
      "profiles/passwords"      :   "editPassword"
      "profiles/invoices"       :   "listInvoices"
      "profiles/instructions"   :   "imInstructions"
      "profiles/notifications"  :   "editNotifications"

    API =
      profile: ->
        new AccountsApp.Profile.Controller
          section: 'profile'

      editPassword: ->
        new AccountsApp.Password.Controller
          section: 'password'

      listInvoices: ->
        new AccountsApp.Invoice.Controller
          section: 'invoices'

      imInstructions: ->
        new AccountsApp.Instructions.Controller
          section: 'instructions'

      editNotifications: ->
       new AccountsApp.Notifications.Controller
         section: 'notifications'
      #
      #listInvoices: ->
      #  new AccountsApp.Show.Controller
      #    section: 'invoices'


    App.addInitializer ->
      new AccountsApp.Router
        controller: API