@Offerchat.module "SettingsApp.Style", (Style, App, Backbone, Marionette, $, _) ->

  class Style.Layout extends App.Views.Layout
    template: "settings/style/layout"
    className: "column-content-container"
    events:
      "click #controlColorContent a" : "changeColor"
      "click .toggle-check"            : "toggleGradient"

    triggers:
      "click #setting-notification" : "hide:notification"

    changeColor: (e) ->
      @trigger "style:color:clicked", e

    toggleGradient: (e) ->
      @trigger "style:gradient:checked", e

    serializeData: ->
      user: @options.user.toJSON()
      website: @options.model.toJSON()
