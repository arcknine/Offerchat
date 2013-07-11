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
    className: "main-content-view"
    form:
      buttons:
        primary: false
        cancel: false