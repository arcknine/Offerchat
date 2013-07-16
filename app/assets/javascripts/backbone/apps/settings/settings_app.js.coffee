@Offerchat.module "SettingsApp", (SettingsApp, App, Backbone, Marionette, $, _) ->

  class SettingsApp.Router extends Marionette.AppRouter
    appRoutes:
      "settings"                    : "show"
      "settings/style"              : "editStyle"
      #"settings/position"           : "editPosition"
      #"settings/attention_grabbers" : "editAttentionGrabbers"
      #"settings/forms"              : "editForms"
      #"settings/triggers"           : "editTriggers"

  API =
    show: ->
      new SettingsApp.Show.Controller
        section: "settings"

    editStyle: ->
      new SettingsApp.Style.Controller
      region: App.mainRegion

  App.addInitializer ->
    new SettingsApp.Router
      controller: API
