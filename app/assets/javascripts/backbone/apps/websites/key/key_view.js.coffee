@Offerchat.module "WebsitesApp.Key", (Key, App, Backbone, Marionette, $, _) ->

  class Key.Code extends App.Views.ItemView
    template:   "websites/key/code"
    className:  "main-content-view tour-content-view"