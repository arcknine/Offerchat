@Offerchat.module "WebsitesApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Website extends App.Views.ItemView
    template:   "websites/new/new"
    className:  "tour-content-inner"

    serializeData: ->
      user: @options.currentUser.toJSON()