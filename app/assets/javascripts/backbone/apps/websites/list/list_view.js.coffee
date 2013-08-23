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

    events:
      "click .block-message a.close" :  "closeNotification"

    closeNotification: (e) ->
      $(e.currentTarget).parent("div").fadeOut()

  class List.ModalWebsite extends App.Views.ItemView
    template: "websites/list/modal"
    className: "form form-inline"
    form:
      buttons:
        primary: "Save changes"
        nosubmit: false
        cancel:  "Cancel"
      title: "Edit Website"

    events:
      "click textarea.widget-text-format" : "highlightCode"
      "click input.apikey" : "highlightCode"

    highlightCode: (ev) ->
      $(ev.currentTarget).select()

