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
          # section: "settings"
          region: App.mainRegion

      editStyle: ->
        show = API.show()
        show.listenTo show.layout, "show", =>
          new SettingsApp.Style.Controller
            region: show.layout.settingsRegion

    App.addInitializer ->
      new SettingsApp.Router
        controller: API


    App.vent.on "show:settings:view", (section) ->
      console.log section
