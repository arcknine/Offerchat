@Offerchat.module "ReportsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    initialize: ->
      reportsView = @getReports()
      console.log reportsView
      App.mainRegion.show reportsView
      NProgress.inc()

    getReports: ->
      new Show.Reports
