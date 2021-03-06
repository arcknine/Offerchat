@Offerchat.module "Components.Modal", (Modal, App, Backbone, Marionette, $, _) ->

  class Modal.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      @contentView = options.view

      @modalLayout = @getModalLayout options.config
      @listenTo @modalLayout, "show", @modalContentRegion
      @listenTo @modalLayout, "modal:submit", @modalSubmit
      @listenTo @modalLayout, "modal:cancel", @modalCancel

      $("#wrapper").addClass("blur")

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
      App.request "hide:preloader"
      $("#wrapper").removeClass("blur")

    modalContentRegion: ->
      modalBody = @modalLayout.$el.find(".block-message")

      App.reqres.setHandler "modal:show:message", (message) ->
        modalBody.removeClass("hide")
        modalBody.text message

      App.reqres.setHandler "modal:error:message", (message) ->
        modalBody.addClass("warning").removeClass("hide")
        modalBody.text message

      App.reqres.setHandler "modal:hide:message", ->
        modalBody.removeClass("warning").addClass("hide")
        modalBody.text ""

      @region = @modalLayout.modalContentRegion
      @show @contentView

    getModalLayout: (options = {}) ->

      config = @getDefaultConfig _.result(@contentView, "form")
      _.extend config, options

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