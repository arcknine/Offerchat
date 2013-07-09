@Offerchat.module "WebsitesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Website extends App.Views.ItemView
    template: "websites/list/website"
    tagName: "li"
    triggers:
      "click button.trash-btn" : "click:delete:website"

  class List.Websites extends App.Views.CompositeView
    template: "websites/list/websites"
    itemView: List.Website
    itemViewContainer: "ul"