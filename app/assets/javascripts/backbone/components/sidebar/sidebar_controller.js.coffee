@Offerchat.module "Components.Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->

  class Sidebar.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      @contentView = options.view

      @sidebarLayout = @getSidebarLayout options.config
      @listenTo @sidebarLayout, "show", @sidebarContentRegion
      @listenTo @sidebarLayout, "sidebar:submit", @sidebarSubmit
      @listenTo @sidebarLayout, "sidebar:cancel", @sidebarCancel

      App.commands.setHandler "close:quick:responses", =>
        @sidebarCancel()

    sidebarCancel: ->
      $(".sidebar-modal-fixed").remove()
      @contentView.triggerMethod "sidebar:cancel"

    sidebarSubmit: ->
      data = Backbone.Syphon.serialize @sidebarLayout

      if @contentView.triggerMethod("sidebar:submit", data) isnt false
        model = @contentView.model
        collection = @contentView.collection
        @processSidebarSubmit data, model, collection

    processSidebarSubmit: (data, model, collection) ->
      model.save data,
        collection: collection

    onClose: ->
      App.request "hide:preloader"

    sidebarContentRegion: ->
      @region = @sidebarLayout.sidebarContentRegion
      @show @contentView

    getSidebarLayout: (options = {}) ->

      config = @getDefaultConfig _.result(@contentView, "form")
      _.extend config, options

      if typeof config.buttons isnt "undefined"
        buttons = @getButtons config.buttons

      if typeof config.title isnt "undefined"
        title = config.title

      new Sidebar.SidebarWrapper
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

  App.reqres.setHandler "sidebar:wrapper", (contentView, options = {}) ->
    throw new Error "No model found inside of sidebar's contentView" unless contentView.model
    sidebarController = new Sidebar.Controller
      view: contentView
      config: options
    sidebarController.sidebarLayout