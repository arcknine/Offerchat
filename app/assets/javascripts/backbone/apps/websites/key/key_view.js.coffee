@Offerchat.module "WebsitesApp.Key", (Key, App, Backbone, Marionette, $, _) ->

  class Key.Code extends App.Views.ItemView
    template:   "websites/key/code"
    className:  "tour-content-view"
    triggers:
      "click button"              : "click:finish:website"
      "click a.webmaster-code"    : "click:send:code"

    events:
      "click textarea.widget-code-text" : "selectAllCode"

    selectAllCode: (ev) ->
      $(ev.currentTarget).select()

  class Key.Modal extends App.Views.ItemView
    template: "websites/key/modal"
    className: "form"
    form:
      buttons:
        primary: " Send "
        nosubmit: false
        cancel:  false
      title: "Send to your Webmaster"
