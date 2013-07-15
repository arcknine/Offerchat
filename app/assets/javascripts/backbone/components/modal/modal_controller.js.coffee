@Offerchat.module "Components.Modal", (Modal, App, Backbone, Marionette, $, _) ->

  class Modal.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      @contentView = options.view
      console.log options.config
      @modalLayout = @getModalLayout options.config
      @listenTo @modalLayout, "show", @modalContentRegion
      @listenTo @modalLayout, "modal:submit", @modalSubmit
      @listenTo @modalLayout, "modal:cancel", @modalCancel
    modalCancel: ->
      @contentView.triggerMethod "modal:cancel"

    modalSubmit: ->
      data = Backbone.Syphon.serialize @modalLayout

      if @contentView.triggerMethod("modal:submit", data) isnt false
        model = @contentView.model
        collection = @contentView.collection
        @processModalSubmit data, model, collection

    processModalSubmit: (data, model, collection) ->
      model.save data,
        collection: collection

    onClose: ->
      console.log "onClose", @

    modalContentRegion: ->
      @region = @modalLayout.modalContentRegion
      @show @contentView

    getModalLayout: (options = {}) ->

      config = @getDefaultConfig _.result(@contentView, "form")
      _.extend config, options
      console.log config

      if typeof config.buttons isnt "undefined"
        buttons = @getButtons config.buttons

      if typeof config.title isnt "undefined"
        title = config.title

      new Modal.ModalWrapper
        config: config
        model: @contentView.model
        buttons: buttons
        title: title

    getDefaultConfig: (config = {}) ->
      console.log config
      _.defaults config,
        title: "New"
        footer: true
        focusFirstInput: true
        errors: true
        syncing: true

    getButtons: (buttons = {}) ->
      App.request("form:button:entities", buttons, @contentView.model) unless buttons is false

  App.reqres.setHandler "modal:wrapper", (contentView, options = {}) ->
    throw new Error "No model found inside of modal's contentView" unless contentView.model
    modalController = new Modal.Controller
      view: contentView
      config: options
    modalController.modalLayout