@Offerchat.module "WebsitesApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize:(options) ->
      console.log "start initializing website controller....."

      website = App.request 'site:new:entity'

      @getMainRegion(options.section, website)

      @listenTo website, "updated", (model) =>
        step = model.get('id')
        if step is "step_three"
          App.navigate '#websites/preview', trigger: true



      console.log "done initializing website controller....."


    getMainRegion: (section,model) ->
      if section is "new"
        model.url = Routes.signup_wizard_path('step_three')
        model.set id:'step_three'
        firstView = @thirdStepView model
        formView = App.request "form:wrapper", firstView
        App.mainRegion.show formView
      else if section is "preview"
        secondView = @fourthStepView model
        formView = App.request "form:wrapper", secondView
        console.log formView
        App.mainRegion.show formView

    thirdStepView: (model) ->
      new Show.FirstStep
        model: model

    fourthStepView: (model) ->
      new Show.SecondStep
        model: model


