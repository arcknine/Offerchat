@Offerchat.module "SettingsApp.AttentionGrabbers", (AttentionGrabbers, App, Backbone, Marionette, $, _) ->

  class AttentionGrabbers.Layout extends App.Views.Layout
    template:  "settings/attention_grabbers/layout"
    className: "column-content-container"

    triggers:
      "click .save-attention-grabber" : "save:attention:grabber"
      "click .browse-more"            : "browse:more:grabbers"

    events:
      "click #attention-grabber-toggle" :  "toggleAttentionGrabber"

    toggleAttentionGrabber: (e) ->
      target = $(e.currentTarget)
      if target.hasClass("toggle-off")
        target.removeClass("toggle-off")
      else
        target.addClass("toggle-off")

    serializeData: ->
      settings = @options.model.get("settings")
      console.log "name is: ", settings.grabber.name
      grabber_src: settings.grabber.src
      grabber_name: settings.grabber.name

  class AttentionGrabbers.Modal extends App.Views.ItemView
    template: "settings/attention_grabbers/modal"
    className: "modal-backdrop"

    events:
      "click a.close" : "closeModal"
      "click a.ag-select" : "selectGrabber"
      "click .cancel-set-attention-grabber" : "closeModal"
      "click .set-attention-grabber"  : "setGrabber"

    closeModal: ->
      $(".modal-backdrop").remove()

    selectGrabber: (e) ->
      $(".ag-select").removeClass("active")
      $(e.currentTarget).addClass("active")

    setGrabber: ->
      @trigger "set:attention:grabber"
      @closeModal()