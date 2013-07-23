@Offerchat.module "WebsitesApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize:(options) ->
      console.log "start initializing website controller....."

      website = App.request 'new:site:entity'

      @getMainRegion(options.section, website)

      @listenTo website, "updated", (model) =>
        console.log model
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
        #formView = App.request "form:wrapper", secondView
        #console.log formView
        @listenTo secondView , "click:back:preview", (item) =>
          App.previewRegion.hideModal secondView
          App.navigate '#websites/new', trigger: true
          console.log "naka click naka!"

        # @listenTo secondView, "click:widgetposition:left", (item) =>
        #   @toggleWidgetPoistion(item,'left')

        # @listenTo secondView, "click:widgetposition:right", (item) =>
        #   @toggleWidgetPoistion(item,'right')

        @listenTo secondView, "click:widget:toggle", (item) =>
          @toggleWidgetPoistion(item,'right')

        App.previewRegion.showModal secondView


        # console.log "awwwwwwwwwwwwww"
        # console.log model
        # App.mainRegion.show formView

    thirdStepView: (model) ->
      new Show.FirstStep
        model: model

    fourthStepView: (model) ->
      new Show.SecondStep
        model: model


    toggleWidgetPoistion: (item,direction) ->
      console.log item
      console.log "awa daw"
      console.log item.view.$el
      # item.view.$el.find(".widget-position-selector > a").removeClass("active")
      # if direction is "left"
      #   item.view.$el.find("a#widgetPositionLeft").addClass("active")
      # else
      #   item.view.$el.find("a#widgetPositionRight").addClass("active")

      # item.view.$el.addClass("active")
      console.log "e toggle na bai!"



