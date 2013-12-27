@Offerchat.module "GettingStartedApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      mainView = @getMainView()
      
      @listenTo mainView, "remove:message", (e) =>
        App.navigate Routes.root_path(), trigger: true
        
      App.mainRegion.show mainView
      
    getMainView: ->
      new Show.Main