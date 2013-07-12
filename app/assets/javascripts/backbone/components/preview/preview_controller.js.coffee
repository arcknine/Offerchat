@Offerchat.module "Components.Preview", (Preview, App, Backbone, Marionette, $, _) ->

  class Preview.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      @contentView = options.view
      @previewLayout = @getPreviewLayout options.config

    getPreviewLayout: (options ={}) ->
      config = @getDefaultConfig _.result(@contentView, "form")
      _.extend config, options

      new Preview.PreviewWrapper
        config: config
        model: @contentView.model
        # buttons: buttons

    getDefaultConfig: (config = {}) ->
      _.defaults config,
        footer: true
        focusFirstInput: true
        errors: true
        syncing: true

  App.reqres.setHandler "preview:wrapper", (contentView, options = {}) ->
    preveiwController = new Preview.Controller
      view: contentView
      config: options

    preveiwController.previewLayout