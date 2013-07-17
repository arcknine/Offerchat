@Offerchat.module "SettingsApp.Position", (Position, App, Backbone, Marionette, $, _) ->

  class Position.Layout extends App.Views.Layout
    template: "settings/position/position"
    className: "column-content-container"