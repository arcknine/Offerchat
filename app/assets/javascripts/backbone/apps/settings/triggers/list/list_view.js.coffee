@Offerchat.module "SettingsApp.TriggersList", (TriggersList, App, Backbone, Marionette, $, _) ->

  class TriggersList.Layout extends App.Views.Layout
    template: "settings/triggers/list/layout"
    className: "column-content-container"

    regions:
      triggersRegion: "#triggers-region"
      emptyRegion:    "#empty-triggers"

    events:
      "click #addTriggerBtn"  :   "addTrigger"
      "click .block-message a.close" :  "closeNotification"

    closeNotification: (e) ->
      $(e.currentTarget).parent("div").fadeOut()

    addTrigger: (e) ->
      App.execute "show:trigger:items"
      @trigger "add:trigger:clicked", e

  class TriggersList.Form extends App.Views.ItemView
    template: "settings/triggers/list/form"

    triggers:
      "click a.save-trigger" : "save:trigger:clicked"
      "click a.remove-trigger" : "remove:trigger:clicked"

    events:
      "change select"           : "changeRule"

    changeRule: (e) ->
      @trigger "rule:changed", e

  class TriggersList.Empty extends App.Views.ItemView
    template: "settings/triggers/list/empty"
    tagName: "div"

  class TriggersList.Trigger extends App.Views.ItemView
    template: "settings/triggers/list/trigger"

    events:
      "click .trigger-item"       : "clickTrigger"

    clickTrigger: (e) ->
      App.execute "show:trigger:items"
      $(e.currentTarget).hide()
      @trigger "trigger:item:clicked"

    modelEvents:
      "updated" :  "render"

  class TriggersList.Triggers extends App.Views.CompositeView
    template: "settings/triggers/list/triggers"
    itemView: TriggersList.Trigger