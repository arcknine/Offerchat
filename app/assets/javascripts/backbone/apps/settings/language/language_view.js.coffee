@Offerchat.module "SettingsApp.Language", (Language, App, Backbone, Marionette, $, _) ->

  class Language.Layout extends App.Views.Layout
    template: "settings/language/layout"
    className: "column-content-container"

    regions:
      languageRegion: "#language-region"
      labelRegion:    "#label-region"

  class Language.Langs extends App.Views.ItemView
    template: "settings/language/languages"
    className: "language-selector"

  class Language.Labels extends App.Views.ItemView
    template: "settings/language/labels"
    className: "group block large"

    # modelEvents:
    #   "change" : "render"

    events:
      "keyup #widget-label" : "changeValue"
      "blur #widget-label"  : "updateValue"

    triggers:
      "click #setting-notification" : "hide:notification"

    changeValue: (e) ->
      @trigger "label:value:changed", e

    updateValue: (e) ->
      @trigger "label:value:update", e

    serializeData: ->
      model: @options.model.toJSON()
      user:  @options.user.toJSON()
      counter: @options.counter