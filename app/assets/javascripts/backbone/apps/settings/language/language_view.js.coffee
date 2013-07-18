@Offerchat.module "SettingsApp.Language", (Language, App, Backbone, Marionette, $, _) ->

  class Language.Layout extends App.Views.Layout
    template: "settings/language/layout"
    className: "column-content-container"

    events:
      "keyup #widget-label" : "changeValue"
      "blur #widget-label"  : "updateValue"

    triggers:
      "click #setting-notification" : "hide:notification"

    changeValue: (e) ->
      @trigger "language:value:changed", e

    updateValue: (e) ->
      @trigger "language:value:update", e