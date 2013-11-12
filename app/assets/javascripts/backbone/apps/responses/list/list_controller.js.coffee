@Offerchat.module "ResponsesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      console.log 'initialize.......'

      @layout = @getLayoutView()
      App.mainRegion.show @layout

    getLayoutView: ->
      new List.Layout
