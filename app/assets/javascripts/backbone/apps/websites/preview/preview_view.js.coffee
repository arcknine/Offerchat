@Offerchat.module "WebsitesApp.Preview", (Preview, App, Backbone, Marionette, $, _) ->

  class Preview.Layout extends App.Views.Layout
    template: "websites/preview/layout"
    regions:
      iframeRegion:   "#website-iframe-region"
      settingsRegion: "#website-settings-region"
      widgetRegion:   "#website-chat-widget-region"

  class Preview.Iframe extends App.Views.ItemView
    template: "websites/preview/iframe"

  class Preview.Settings extends App.Views.ItemView
    template:  "websites/preview/settings"
    className: "control-modal"
    triggers:
      "click .control-footer a.btn":                        "click:back:new"

  class Preview.Widget extends App.Views.ItemView
    template: "websites/preview/widget"
    className: "widget-box widget-theme theme-darkslategrey"


  class Preview.Colors extends App.Views.CompositeView
    template: "websites/preview/colors"
    className: "control-modal"
    triggers:
      "click .control-footer a.btn":                        "click:back:greeting"
    events:
      "click .widget-color-selector a": 'select_color'
      "click #checkboxGradient": 'gradient_toggle'
      "click #checkboxRadius": 'rounded_corners_toggle'

    rounded_corners_toggle: (e) ->
      if $(e.currentTarget).hasClass("checked")
        $(e.currentTarget).removeClass "checked"
        cornerValue = "false"
      else
        $(e.currentTarget).addClass "checked"
        cornerValue = "true"

      @trigger "rounded:corners:toggle", cornerValue
    gradient_toggle: (e) ->
      if $(e.currentTarget).hasClass("checked")
        $(e.currentTarget).removeClass "checked"
        gradientValue = "false"
      else
        $(e.currentTarget).addClass "checked"
        gradientValue = "true"

      @trigger "gradient:toggle", gradientValue
    select_color: (e)->
      $(e.currentTarget).parent('div').find('a').removeClass('active')
      colorValue = $(e.currentTarget).attr('class')
      $(e.currentTarget).addClass('active')
      @trigger "select:color", colorValue

  class Preview.Position extends App.Views.ItemView
    template: "websites/preview/position"
    className: "control-modal"
    triggers:
      "click .control-footer a.btn":                        "click:back:color"
    events:
      "click .widget-position-selector a" : 'select_position'
    select_position: (e) ->
      $(e.currentTarget).parent('div').find('a').removeClass('active')
      positionValue = $(e.currentTarget).attr('id')
      $(e.currentTarget).addClass('active')

      @trigger "select:position", positionValue





