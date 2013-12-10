@Offerchat.module "WebsitesApp.Preview", (Preview, App, Backbone, Marionette, $, _) ->

  class Preview.Controller extends App.Controllers.Base

    initialize: ->
      currentUser = App.request "get:current:profile"
      @storage = JSON.parse(sessionStorage.getItem("newSite"))
      website = App.request "new:site:entity"
      website.url = Routes.signup_wizard_path('step_three')
      website.set id:'step_three'


      @layout = @getLayoutView()
      App.execute "when:fetched", currentUser, =>
        @listenTo @layout, "show", =>
          @iframeRegion website
          @settingsRegion website
          @widgetRegion currentUser

        App.previewRegion.show @layout

        mixpanel.track("Preview Website")


    iframeRegion: (website) ->
      iframeView = @getIframeView website
      @layout.iframeRegion.show iframeView

    widgetRegion: (currentUser) ->
      widgetView = @getWidgetView currentUser
      @layout.widgetRegion.show widgetView

    settingsRegion: (website) ->
      @showSettingsView website

      @listenTo website, "updated", (model) =>
        currentForm = model.get('step')
        if currentForm is 'greeting'
          @storage.greeting = model.get('greeting')
          sessionStorage.setItem("newSite", JSON.stringify(@storage))

          if model.get('greeting') is ''
            @toggleErrorDisplay('show')
          else
            @toggleErrorDisplay('hide')
            @showColorView model
        else if currentForm is 'colors'
          @storage.color = model.get('color')
          @storage.rounded = model.get('rounded')
          @storage.gradient = model.get('gradient')
          sessionStorage.setItem("newSite", JSON.stringify(@storage))
          @showPositionView model
        else  if currentForm is 'position'
          @storage.position = model.get('position')
          sessionStorage.setItem("newSite", JSON.stringify(@storage))
          App.previewRegion.close()
          # App.vent.trigger "show:chat:sidebar"
          App.navigate 'websites/info', trigger: true


    getColorView: (website)->
      new Preview.Colors
        model: website

    getColorView: (website)->
      new Preview.Colors
        model: website

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

    getWidgetView: (currentUser) ->
      new Preview.Widget
        model: currentUser

    showSettingsView:(model) ->
      settingsView = @getSettingsView model
      formSettings = App.request "form:wrapper", settingsView
      @layout.settingsRegion.show formSettings

      @listenTo settingsView, "click:back:new", (item) ->
        App.previewRegion.close()
        App.navigate 'websites/new', trigger: true
      @listenTo settingsView, "keyup:change:greeting", (item) ->

      @initSettingsView()


    showColorView: (model) ->

      colorView = @getColorView(model)
      formSettings = App.request "form:wrapper", colorView
      @layout.settingsRegion.show formSettings

      @initColorView(model)

      @listenTo colorView , "select:color", (item) ->
        model.set color: item
      @listenTo colorView, "gradient:toggle", (item) ->
        model.set gradient: item
      @listenTo colorView, "rounded:corners:toggle", (item) ->
        model.set rounded: item

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
      rounded = model.get('rounded')
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
      # App.selectorSidebarRegion.close()

    toggleErrorDisplay:(status) ->
      if status is 'show'
        $("#greeting-name").addClass("field-error")
        $("#greeting-name-error").show()
      else
        $("#greeting-name").removeClass("field-error")
        $("#greeting-name-error").hide()




