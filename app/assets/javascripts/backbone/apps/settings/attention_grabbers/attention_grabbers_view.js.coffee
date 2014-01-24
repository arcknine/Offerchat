@Offerchat.module "SettingsApp.AttentionGrabbers", (AttentionGrabbers, App, Backbone, Marionette, $, _) ->

  class AttentionGrabbers.Layout extends App.Views.Layout
    template:  "settings/attention_grabbers/layout"
    className: "column-content-container"

    triggers:
      "click .save-attention-grabber" : "save:attention:grabber"

    events:
      "click #attention-grabber-toggle" :  "toggleAttentionGrabber"

    toggleAttentionGrabber: (e) ->
      target = $(e.currentTarget)
      if target.hasClass("toggle-off")
        target.removeClass("toggle-off")
      else
        target.addClass("toggle-off")

