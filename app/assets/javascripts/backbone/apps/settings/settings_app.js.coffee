@Offerchat.module "SettingsApp", (SettingsApp, App, Backbone, Marionette, $, _) ->

  class SettingsApp.Router extends Marionette.AppRouter
    appRoutes:
      "settings"                        : "show"
      "settings/style/:id"              : "editStyle"
      "settings/position/:id"           : "editPosition"
      "settings/chat-forms/:id"         : "editForms"
      "settings/chat-forms/:id/prechat" : "prechatForm"
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

      editForms: (id) ->
        show = API.show(id, 'chat-forms')
        show.listenTo show.layout, "show", =>
          new SettingsApp.ChatForms.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite
            section: 'offline'

      prechatForm: (id) ->
        show = API.show(id, 'chat-forms')
        show.listenTo show.layout, "show", =>
          new SettingsApp.ChatForms.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite
            section: 'prechat'

    App.addInitializer ->
      new SettingsApp.Router
        controller: API
