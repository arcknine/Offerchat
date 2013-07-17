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
        console.log 'check ang data!!'
        console.log model
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

    initColorView:(model) ->
      color = model.get('color')
      gradient = model.get('gradient')
      rounded = model.get('rounded_corners')
      console.log 'awa: '+ color
      $(".widget-color-selector a").removeClass("active")
      $("#controlColorContent a.#{color}").addClass("active")
      if( gradient == 'true')
      $("#checkboxGradient#{color}").removeClass()
      # $("#widget-header").addClass("widget-box widget-theme theme-#{website.attributes.settings.style.theme}")

    getPositionView: (website)->
      new Preview.Position
        model: website

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

    showColorView: (model) ->

      colorView = @getColorView(model)
      formSettings = App.request "form:wrapper", colorView
      @layout.settingsRegion.show formSettings

      @initColorView(model)

      @listenTo colorView , "select:color", (item) ->
        console.log "selected color: "+item
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











