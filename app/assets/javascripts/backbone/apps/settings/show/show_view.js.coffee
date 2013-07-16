@Offerchat.module "SettingsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "settings/show/layout"
    tagName:  "span"

    regions:
      sitesRegion:    "#settings-websites"
      settingsRegion: "#settings-main-region"

    triggers:
      "click a.language"           : "nav:language:clicked"
      "click a.style-and-color"    : "nav:style:clicked"

  class Show.Style extends App.Views.ItemView
    template:  "settings/show/style"
    className: "column-content-container"
    events:
      "click #controlColorContent a" : "changeColor"

    changeColor: (e) ->
      @trigger "style:color:clicked", e

    form:
      buttons:
        primary: "Save Changes"
        cancel: false