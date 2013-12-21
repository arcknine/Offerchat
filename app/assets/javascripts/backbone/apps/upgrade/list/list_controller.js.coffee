@Offerchat.module "UpgradeApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->

      # plans = App.request "get:plans"
      # @profile = App.request "get:current:profile"

      @layout = @getLayout()

      App.mainRegion.show @layout

    getLayout: ->
      new List.Layout
