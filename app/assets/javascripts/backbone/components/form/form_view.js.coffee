@Offerchat.module "Components.Form", (Form, App, Backbone, Marionette, $, _) ->

  class Form.FormWrapper extends App.Views.Layout
    template: "form/form"

    tagName: "form"
    attributes: ->
      "data-type": @getFormDataType()
      "enctype": "multipart/form-data"

    regions:
      formContentRegion: "#form-content-region"

    ui:
      buttonContainer: "ul.inline-list"

    triggers:
      "submit"                            : "form:submit"
      "click [data-form-button='cancel']"  : "form:cancel"

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

    getFormDataType: ->
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
      sm = $("<span>", class: 'inline-label-message').text(error)
      el.closest("fieldset").addClass("field-error").children().first().append(sm)

    syncStart: (model) ->
      @addOpacityWrapper() if @config.syncing

    syncStop: (model) ->
      @addOpacityWrapper(false) if @config.syncing