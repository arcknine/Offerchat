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

        @listenTo secondView , "click:back:preview", (item) =>
          App.modalRegion.hideModal secondView
          App.navigate '#websites/new', trigger: true

        @listenTo secondView, "click:widget:toggle", (item) =>
          @toggleWidgetPoistion(item,'right')

        App.modalRegion.showModal secondView


    thirdStepView: (model) ->
      new Show.FirstStep
        model: model

    fourthStepView: (model) ->
      new Show.SecondStep
        model: model


    toggleWidgetPoistion: (item,direction) ->

      item.view.$el.find(".widget-position-selector > a").removeClass("active")
      if direction is "left"
        item.view.$el.find("a#widgetPositionLeft").addClass("active")
      else
        item.view.$el.find("a#widgetPositionRight").addClass("active")

      # item.view.$el.addClass("active")
      console.log "e toggle na bai!"



