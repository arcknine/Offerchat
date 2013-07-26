@Offerchat.module "WebsitesApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
      template: "websites/show/layout"
      regions:
        websiteIframeRegion:                        "#website-iframe-region"
        websiteSettingsRegion:                      "#website-settings-region"
        websiteChatWidgetRegion:                    "#website-chat-widget-region"

  class Show.FirstStep extends App.Views.ItemView
    template: "websites/show/new"
    className: "main-content-view tour-content-view"
    form:
      buttons:
        primary: false
        cancel: false


  class Show.Iframe extends App.Views.ItemView
    template: "websites/show/iframe"


  class Show.SecondStep extends App.Views.ItemView
    template: "websites/show/preview"
    triggers:
      "click a.btn":                        "click:back:preview"
      # "click a#widgetPositionLeft":         "click:widgetposition:left"
      # "click a#widgetPositionRight":        "click:widgetposition:right"
      "click .widget-position-selector a":   "click:widget:toggle"
    form:
      buttons:
        primary: false
        cancel: false