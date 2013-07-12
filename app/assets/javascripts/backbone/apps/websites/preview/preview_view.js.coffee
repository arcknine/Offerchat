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
    events:
      "keyup .input-append input": "greetings_count"

    greetings_count: (e) ->
      maxlength = 33
      greetingValue = $(e.currentTarget).val()
      greetingLenght = maxlength - greetingValue.length
      $('.widget-welcome-msg').text(greetingValue)
      $('#greeting-count').text(greetingLenght)
      @trigger "keyup:change:greeting", greetingValue


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
        $('.widget-head').removeClass('widget-rounded-head')
        cornerValue = "false"
      else
        $(e.currentTarget).addClass "checked"
        $('.widget-head').addClass('widget-rounded-head')
        cornerValue = "true"

      @trigger "rounded:corners:toggle", cornerValue
    gradient_toggle: (e) ->
      if $(e.currentTarget).hasClass("checked")
        $(e.currentTarget).removeClass "checked"
        $('.widget-head').removeClass('widget-gradient')
        gradientValue = "false"

      else
        $(e.currentTarget).addClass "checked"
        $('.widget-head').addClass('widget-gradient')
        gradientValue = "true"


      @trigger "gradient:toggle", gradientValue
    select_color: (e)->
      $(e.currentTarget).parent('div').find('a').removeClass('active')
      colorValue = $(e.currentTarget).attr('class')
      $(e.currentTarget).addClass('active')
      classStr = $('.widget-box').attr('class')
      lastClass = classStr.substr( classStr.lastIndexOf(' ') + 1);
      $('.widget-box').removeClass(lastClass)
      $('.widget-box').addClass('theme-'+colorValue)
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
      classStr = $('.widget-wrapper').attr('class')
      lastClass = classStr.substr( classStr.lastIndexOf(' ') + 1);
      $('.widget-wrapper').removeClass(lastClass)
      if positionValue is 'left'
        $('.widget-wrapper').addClass('widget-fixed-left')
      else
        $('.widget-wrapper').addClass('widget-fixed-right')

      @trigger "select:position", positionValue






