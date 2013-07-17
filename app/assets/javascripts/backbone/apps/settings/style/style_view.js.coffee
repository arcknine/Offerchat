@Offerchat.module "SettingsApp.Style", (Style, App, Backbone, Marionette, $, _) ->

  class Style.Layout extends App.Views.Layout
    template: "settings/style/layout"
    className: "column-content-container"