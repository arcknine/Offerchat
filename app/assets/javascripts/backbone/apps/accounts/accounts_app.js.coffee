@Offerchat.module "AccountsApp", (AccountsApp, App, Backbone, Marionette, $, _) ->

  class AccountsApp.Router extends Marionette.AppRouter
    appRoutes:
      "profiles"                :   "show"
      "profiles/passwords"      :   "editPassword"
      "profiles/notifications"  :   "editNotifications"
      "profiles/invoices"       :   "listInvoices"

    API =
      show: ->
        new AccountsApp.Show.Controller
          section: "profile"

      editPassword: ->
        new AccountsApp.Show.Controller
          section: "password"

      editNotifications: ->
        new AccountsApp.Show.Controller
          section: 'notifications'

      listInvoices: ->
        new AccountsApp.Show.Controller
          section: 'invoices'


    App.addInitializer ->
      new AccountsApp.Router
        controller: API