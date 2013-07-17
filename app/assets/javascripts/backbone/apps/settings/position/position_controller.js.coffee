@Offerchat.module "SettingsApp.Position", (Position, App, Backbone, Marionette, $, _) ->
  class Position.Controller extends App.Controllers.Base

    initialize: (options) ->
      @layout = @getLayoutView()
      @show @layout

    getLayoutView: ->
      new Position.Layout