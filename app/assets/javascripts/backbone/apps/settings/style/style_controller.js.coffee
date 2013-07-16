@Offerchat.module "SettingsApp.Style", (Style, App, Backbone, Marionette, $, _) ->
  class Style.Controller extends App.Controllers.Base

    initialize: (options) ->
      @layout = @getLayoutView()
      @show @layout

    getLayoutView: ->
      new Style.Layout