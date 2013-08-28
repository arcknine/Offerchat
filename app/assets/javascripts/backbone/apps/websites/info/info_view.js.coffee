@Offerchat.module "WebsitesApp.Info", (Info, App, Backbone, Marionette, $, _) ->

  class Info.Website extends App.Views.ItemView
    template:   "websites/info/name"
    className:  "tour-content-view"