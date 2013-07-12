@Offerchat.module "WebsitesApp.Show", (Show, App, Backbone, Marionette, $, _) ->


  class Show.FirstStep extends App.Views.ItemView
    template: "websites/show/new"
    className: "main-content-view tour-content-view"
    form:
      buttons:
        primary: false
        cancel: false

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