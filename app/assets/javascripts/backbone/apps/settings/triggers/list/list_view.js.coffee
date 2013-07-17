@Offerchat.module "SettingsApp.TriggersList", (TriggersList, App, Backbone, Marionette, $, _) ->

  class TriggersList.Layout extends App.Views.Layout
    template: "settings/triggers/list/layout"
    className: "column-content-container"

    regions:
      triggersRegion: "#triggers-region"

    events:
      "click #addTriggerBtn"  :   "addTrigger"

    addTrigger: (e) ->
      @trigger "add:trigger:clicked", e

  class TriggersList.Form extends App.Views.ItemView
    template: "settings/triggers/list/form"

  class TriggersList.Trigger extends App.Views.ItemView
    template: "settings/triggers/list/trigger"

    triggers:
      "click .trigger-item"      : "trigger:item:clicked"

  class TriggersList.Triggers extends App.Views.CompositeView
    template: "settings/triggers/list/triggers"
    itemView: TriggersList.Trigger