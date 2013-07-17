@Offerchat.module "WebsitesApp.Preview", (Preview, App, Backbone, Marionette, $, _) ->

  class Preview.Controller extends App.Controllers.Base

    initialize: ->
      @storage = JSON.parse(sessionStorage.getItem("newSite"))
      website = App.request "site:new:entity"
      website.url = Routes.signup_wizard_path('step_three')
      website.set id:'step_three'

      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @iframeRegion website
        @settingsRegion website
        @widgetRegion website

      App.previewRegion.show @layout


    iframeRegion: (website) ->
      iframeView = @getIframeView website
      @layout.iframeRegion.show iframeView

    widgetRegion: (website) ->
      widgetView = @getWidgetView website
      @layout.widgetRegion.show widgetView

    settingsRegion: (website) ->
      @showSettingsView website
      @listenTo website, "updated", (model) =>

        currentForm = model.get('step')
        if currentForm is 'greeting'
          model.set greeting: model.get('greeting')
          # @storage.greeting = model.get('greeting')
          sessionStorage.setItem("newSite", JSON.stringify(@storage))
          @showColorView model
        else if currentForm is 'colors'
          @storage.color = model.get('color')
          sessionStorage.setItem("newSite", JSON.stringify(@storage))
          @showPositionView model
        else  if currentForm is 'position'
          @storage.position = model.get('position')
          # @storage.color = model.get('color')
          # @storage.greeting = model.get('greeting')
          sessionStorage.setItem("newSite", JSON.stringify(@storage))
          # @listenTo website, "sync:stop", =>
          App.previewRegion.close()
          App.navigate 'websites/info', trigger: true


    getColorView: (website)->
      new Preview.Colors
        model: website

<<<<<<< HEAD
        currentForm = model.get('step')
        if currentForm is 'greeting'
          model.set greeting: model.get('greeting')
          # @storage.greeting = model.get('greeting')
          sessionStorage.setItem("newSite", JSON.stringify(@storage))
          @showColorView model
        else if currentForm is 'colors'
          @storage.color = model.get('color')
          sessionStorage.setItem("newSite", JSON.stringify(@storage))
          @showPositionView model
        else  if currentForm is 'position'
          @storage.position = model.get('position')
          # @storage.color = model.get('color')
          # @storage.greeting = model.get('greeting')
          sessionStorage.setItem("newSite", JSON.stringify(@storage))
          # @listenTo website, "sync:stop", =>
          App.previewRegion.close()
          App.navigate 'websites/info', trigger: true


    getColorView: (website)->
      new Preview.Colors
        model: website

=======
>>>>>>> added error trapping on registration
    getPositionView: (website)->
      new Preview.Position
        model: website

    getColorView: ->
      new Preview.Color

    getLayoutView: ->
      new Preview.Layout

    getIframeView: (website) ->
      new Preview.Iframe
        model: website

    getSettingsView: (website) ->
      new Preview.Settings
        model: website

    getWidgetView: ->
      new Preview.Widget

    showSettingsView:(model) ->
      settingsView = @getSettingsView model
      formSettings = App.request "form:wrapper", settingsView
      @layout.settingsRegion.show formSettings

      @listenTo settingsView, "click:back:new", (item) ->
        App.previewRegion.close()
        App.navigate 'websites/new', trigger: true
      @listenTo settingsView, "keyup:change:greeting", (item) ->

      @initSettingsView()

      @listenTo settingsView, "keyup:change:greeting", (item) ->

      @initSettingsView()


    showColorView: (model) ->

      colorView = @getColorView(model)
      formSettings = App.request "form:wrapper", colorView
      @layout.settingsRegion.show formSettings

      @initColorView(model)

      @listenTo colorView , "select:color", (item) ->
<<<<<<< HEAD

=======
>>>>>>> added error trapping on registration
        model.set color: item
      @listenTo colorView, "gradient:toggle", (item) ->
        model.set gradient: item
      @listenTo colorView, "rounded:corners:toggle", (item) ->
        model.set rounded_corners: item

      @listenTo colorView, "click:back:greeting", (item) ->
        @showSettingsView model


    showPositionView: (model) ->
      positionView = @getPositionView model
      formSettings = App.request "form:wrapper", positionView
      @layout.settingsRegion.show formSettings

      @listenTo positionView , "select:position", (item) ->
        model.set position: item

      @listenTo positionView, "click:back:color", (item) ->
        @showColorView model

    initColorView:(model) ->
      color = model.get('color')
      gradient = model.get('gradient')
      rounded = model.get('rounded_corners')
      $(".widget-color-selector a").removeClass("active")
      $("#controlColorContent a.#{color}").addClass("active")
      if gradient is 'true'
        $("#checkboxGradient").addClass('checked')
      if rounded is 'true'
        $("#checkboxRadius").addClass('checked')

    initSettingsView:(model) ->
      counterValue = $("#greeting").val()
      remainLength = 33 - counterValue.length
      $("#greeting-count").text(remainLength)


