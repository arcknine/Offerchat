@Offerchat.module "SettingsApp.Style", (Style, App, Backbone, Marionette, $, _) ->

  class Style.Layout extends App.Views.Layout
    template: "settings/style/layout"
    className: "column-content-container"
    events:
      "click #controlColorContent a" : "changeColor"
      "click .icon-check"            : "toggleGradient"

    changeColor: (e) ->
      @trigger "style:color:clicked", e

    toggleGradient: (e) ->
      @trigger "style:gradient:checked", e

    form:
      buttons:
        primary: "Save Changes"
        cancel: false