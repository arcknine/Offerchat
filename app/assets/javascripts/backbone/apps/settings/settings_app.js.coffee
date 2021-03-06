@Offerchat.module "SettingsApp", (SettingsApp, App, Backbone, Marionette, $, _) ->

  class SettingsApp.Router extends Marionette.AppRouter
    appRoutes:
      "settings"                         : "show"
      "settings/style/:id"               : "editStyle"
      "settings/position/:id"            : "editPosition"
      "settings/language/:id"            : "editLanguage"
      "settings/chat-forms/:id/offline"  : "chatForms"
      "settings/chat-forms/:id"          : "prechatForm"
      "settings/chat-forms/:id/postchat" : "postChatForm"
      "settings/triggers/:id"            : "editTriggers"
      "settings/attention-grabbers/:id"  : "attentionGrabbers"
      "settings/language/:id"            : "editLanguage"
      "settings/integrations/:id"        : "showIntegrations"

    API =
      show: (id, section, sub_form) ->
        new SettingsApp.Show.Controller
          region: App.mainRegion
          id: id
          section: section
          subForm: sub_form

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

      chatForms: (id) ->
        show = API.show(id, 'chat-forms', 'offline')
        show.listenTo show.layout, "show", =>
          new SettingsApp.ChatForms.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite
            section: 'offline'

      prechatForm: (id) ->
        show = API.show(id, 'chat-forms', 'prechat')
        show.listenTo show.layout, "show", =>
          new SettingsApp.ChatForms.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite
            section: 'prechat'

      postChatForm: (id) ->
        show = API.show(id, 'chat-forms', 'postchat')
        show.listenTo show.layout, "show", =>
          new SettingsApp.ChatForms.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite
            section: 'postchat'

      editLanguage: (id) ->
        show = API.show(id, 'language')
        show.listenTo show.layout, "show", =>
          new SettingsApp.Language.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite

      editTriggers: (id) ->
        show = API.show(id, 'triggers')
        show.listenTo show.layout, "show", =>
          new SettingsApp.TriggersList.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite

      attentionGrabbers: (id) ->
        show = API.show(id, 'attention-grabbers')
        show.listenTo show.layout, "show", =>
          new SettingsApp.AttentionGrabbers.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite

      showIntegrations: (id) ->
        show = API.show(id, 'integrations')
        show.listenTo show.layout, "show", =>
          new SettingsApp.Integrations.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite

    App.addInitializer ->
      new SettingsApp.Router
        controller: API
