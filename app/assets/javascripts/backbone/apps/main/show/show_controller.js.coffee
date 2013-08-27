@Offerchat.module "MainApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      mainView = @getMainView()

      App.mainRegion.show mainView

      App.reqres.setHandler "new:site:created", =>
        @showNotification("Your website has been added successfully!")

    getMainView: ->
      new Show.Main