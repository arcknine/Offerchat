@Offerchat.module "WebsitesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Websites extends App.Views.ItemView
    template: "websites/list/websites"