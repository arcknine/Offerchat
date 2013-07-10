@Offerchat.module "WebsitesApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      console.log "kita ka?"
      website = App.request 'site:new:entity'

      firstView = @firstStepView website
      formView = App.request "form:wrapper", firstView

      # @listenTo firstView, "step:one:submit", (item) =>
      #   console.log item
      #   console.log 'imong na click ang submit !'

      App.mainRegion.show formView



    firstStepView: (model) ->
      new Show.FirstStep
        model: model