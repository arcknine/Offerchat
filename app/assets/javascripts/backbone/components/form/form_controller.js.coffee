@Offerchat.module "Components.Form", (Form, App, Backbone, Marionette, $, _) ->

  class Form.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      @contentView = options.view

      @formLayout = @getFormLayout options.config
      @listenTo @formLayout, "show", @formContentRegion
      @listenTo @formLayout, "form:submit", @formSubmit
      @listenTo @formLayout, "form:cancel", @formCancel

    formCancel: ->
      @contentView.triggerMethod "form:cancel"

    formSubmit: ->
      data = Backbone.Syphon.serialize @formLayout

      if @contentView.triggerMethod("form:submit", data) isnt false
        model = @contentView.model
        collection = @contentView.collection
        @processFormSubmit data, model, collection

    processFormSubmit: (data, model, collection) ->
      model.save data,
        collection: collection

    onClose: ->
      # console.log "onClose", @
      App.request "hide:preloader"

    formContentRegion: ->
      @region = @formLayout.formContentRegion
      @show @contentView

    getFormLayout: (options = {}) ->

      config = @getDefaultConfig _.result(@contentView, "form")
      _.extend config, options
      
      if typeof config.btncontainercls isnt "undefined"
        btncontainercls = config.btncontainercls

      if typeof config.buttons isnt "undefined"
        buttons = @getButtons config.buttons

      new Form.FormWrapper
        config: config
        model: @contentView.model
        buttons: buttons
        btncontainercls: btncontainercls

    getDefaultConfig: (config = {}) ->
      _.defaults config,
        footer: true
        focusFirstInput: true
        errors: true
        syncing: true

    getButtons: (buttons = {}) ->
      App.request("form:button:entities", buttons, @contentView.model) unless buttons is false

  App.reqres.setHandler "form:wrapper", (contentView, options = {}) ->
    throw new Error "No model found inside of form's contentView" unless contentView.model
    formController = new Form.Controller
      view: contentView
      config: options
    formController.formLayout