@Offerchat.module "MainApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      mainView = @getMainView()

      App.mainRegion.show mainView

    getMainView: ->
      new Show.Main