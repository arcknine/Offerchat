@Offerchat.module "WebsitesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Website extends App.Views.ItemView
    template: "websites/list/website"
    tagName: "li"
    modelEvents:
      "updated" :  "render"
    triggers:
      "click button.trash-btn"  : "click:delete:website"
      "click a.block-list-item" : "click:edit:website"

  class List.Websites extends App.Views.CompositeView
    template: "websites/list/websites"
    itemView: List.Website
    itemViewContainer: "ul"
    triggers:
      "click a#new-website" : "click:new:website"

  class List.ModalWebsite extends App.Views.ItemView
    template: "websites/list/modal"
    className: "form form-inline"
    form:
      buttons:
        primary: "Save changes"
        cancel:  "Cancel"