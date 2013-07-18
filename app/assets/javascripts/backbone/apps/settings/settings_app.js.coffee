@Offerchat.module "SettingsApp", (SettingsApp, App, Backbone, Marionette, $, _) ->

  class SettingsApp.Router extends Marionette.AppRouter
    appRoutes:
      "settings"                     : "show"
      "settings/style/:id"           : "editStyle"
      "settings/position/:id"        : "editPosition"
      "settings/language/:id"        : "editLanguage"
      #"settings/attention_grabbers" : "editAttentionGrabbers"
      #"settings/forms"              : "editForms"
      #"settings/triggers"           : "editTriggers"

    API =
      show: (id, section) ->
        new SettingsApp.Show.Controller
          region: App.mainRegion
          id: id
          section: section

      editStyle: (id) ->
        show = API.show(id, 'style')
        show.listenTo show.layout, "show", =>
          new SettingsApp.Style.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite

      editPosition: (id) ->
        show = API.show(id, 'position')
        show.listenTo show.layout, "show", =>
          new SettingsApp.Position.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite

      editLanguage: (id) ->
        show = API.show(id, 'language')
        show.listenTo show.layout, "show", =>
          new SettingsApp.Language.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite

    App.addInitializer ->
      new SettingsApp.Router
        controller: API

    App.vent.on "show:settings:view", (section) ->
      console.log section
