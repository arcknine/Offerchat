@Offerchat.module "SettingsApp", (SettingsApp, App, Backbone, Marionette, $, _) ->

  class SettingsApp.Router extends Marionette.AppRouter
    appRoutes:
      "settings"                     : "show"
      "settings/style/:id"           : "editStyle"
      "settings/position/:id"        : "editPosition"
      #"settings/attention_grabbers" : "editAttentionGrabbers"
      #"settings/forms"              : "editForms"
      #"settings/triggers"           : "editTriggers"

    API =
      show: (id) ->
        new SettingsApp.Show.Controller
          region: App.mainRegion
          id: id

      editStyle: (id) ->
        show = API.show(id)
        show.listenTo show.layout, "show", =>
          new SettingsApp.Style.Controller
            region: show.layout.settingsRegion
            currentSite: show.currentSite

      editPosition: (id) ->
        show = API.show(id)
        # show.listenTo show.layout, "show", =>
        #   new SettingsApp.Style.Controller
        #     region: show.layout.settingsRegion
        #     currentSite: show.currentSite

    App.addInitializer ->
      new SettingsApp.Router
        controller: API


    App.vent.on "show:settings:view", (section) ->
      console.log section
