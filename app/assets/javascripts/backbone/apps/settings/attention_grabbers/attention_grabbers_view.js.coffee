@Offerchat.module "SettingsApp.AttentionGrabbers", (AttentionGrabbers, App, Backbone, Marionette, $, _) ->

  class AttentionGrabbers.Layout extends App.Views.Layout
    template:  "settings/attention_grabbers/layout"
    className: "column-content-container"