@Offerchat.module "SettingsApp", (SettingsApp, App, Backbone, Marionette, $, _) ->

  class SettingsApp.Router extends Marionette.AppRouter
    appRoutes:
      "settings"                    : "show"
      "settings/language"           : "editLanguage"
      "settings/style"              : "editStyle"
      #"settings/position"           : "editPosition"
      #"settings/attention_grabbers" : "editAttentionGrabbers"
      #"settings/forms"              : "editForms"
      #"settings/triggers"           : "editTriggers"

  API =
    show: ->
      new SettingsApp.Show.Controller
        section: "settings"

    editLanguage: ->
      new SettingsApp.Show.Controller
        section: "language"

    editStyle: ->
      new SettingsApp.Show.Controller
        section: "style-and-color"

  App.addInitializer ->
    new SettingsApp.Router
      controller: API
