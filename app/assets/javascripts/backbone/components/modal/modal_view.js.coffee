@Offerchat.module "Components.Modal", (Modal, App, Backbone, Marionette, $, _) ->

  class Modal.ModalWrapper extends App.Views.Layout
    template: "modal/modal"

    tagName: "modal"
    attributes: ->
      "data-type": @getModalDataType()

    regions:
      modalContentRegion: "#modal-content-region"

    ui:
      buttonContainer: "ul.inline-list"

    triggers:
      "submit"                              : "modal:submit"
      "click [data-modal-button='cancel']"  : "modal:cancel"
      "click  a.close"                      : "modal:close"

    modelEvents:
      "change:_errors"   : "changeErrors"
      "sync:start"       :  "syncStart"
      "sync:stop"        :  "syncStop"

    initialize: ->
      @setInstancePropertiesFor "config", "buttons"

    serializeData: ->
      footer: @config.footer
      buttons: @buttons?.toJSON() ? false

    onShow: ->
      _.defer =>
        @focusFirstInput() if @config.focusFirstInput
        @buttonPlacement() if @buttons

    buttonPlacement: ->
      @ui.buttonContainer.addClass @buttons.placement

    focusFirstInput: ->
      @$(":input:visible:enabled:first").focus()

    getModalDataType: ->
      if @model.isNew() then "new" else "edit"

    changeErrors: (model, errors, options) ->
      if @config.errors
        if _.isEmpty(errors) then @removeErrors() else @addErrors errors

    removeErrors: ->
      @$(".field-error").removeClass("field-error").find("span").remove()

    addErrors: (errors = {}) ->
      for name, array of errors
        @addError name, array[0]

    addError: (name, error) ->
      el = @$("[name='#{name}']")
      sm = $("<div>", class: 'block-text-message').text(error)
      el.closest("fieldset").addClass("field-error")
      el.parent().append(sm)

    syncStart: (model) ->
      @addOpacityWrapper() if @config.syncing

    syncStop: (model) ->
      @addOpacityWrapper(false) if @config.syncing