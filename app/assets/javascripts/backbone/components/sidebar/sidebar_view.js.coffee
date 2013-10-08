@Offerchat.module "Components.Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->

  class Sidebar.SidebarWrapper extends App.Views.Layout
    template: "sidebar/sidebar"

    tagName: "form"
    attributes: ->
      "data-type": @getSidebarDataType()

    regions:
      sidebarContentRegion: ".modal-sidebar-viewer"

    ui:
      buttonContainer: "ul.inline-list"
      
    triggers:
      "click [data-form-button='nosubmit']"   : "sidebar:unsubmit"
      "click [data-form-button='primary']"    : "sidebar:submit"
      "click [data-form-button='cancel']"     : "sidebar:cancel"
      "click  a.close"                        : "sidebar:cancel"
      "click  div.close-sidebar-backdrop"     : "sidebar:cancel"
    modelEvents:
      "change:_errors"   : "changeErrors"
      "sync:start"       :  "syncStart"
      "sync:stop"        :  "syncStop"

    initialize: ->
      @setInstancePropertiesFor "config", "buttons"

    serializeData: ->
      title: @config.title
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

    getSidebarDataType: ->
      if @model.isNew() then "new" else "edit"

    changeErrors: (model, errors, options) ->
      if @config.errors
        if _.isEmpty(errors) then @removeErrors() else @addErrors errors

    removeErrors: ->
      @$(".field-error").removeClass("field-error").find(".block-text-message").remove()

    addErrors: (errors = {}) ->
      for name, array of errors
        @addError name, array[0]

    addError: (name, error) ->
      el = @$("[name='#{name}']")
      sm = $("<div>", class: 'block-text-message').text(error)
      el.closest("fieldset").addClass("field-error")
      el.parent().append(sm)

    syncStart: (model) ->
      App.request "show:preloader"
      @addOpacityWrapper() if @config.syncing

    syncStop: (model) ->
      App.request "hide:preloader"
      @addOpacityWrapper(false) if @config.syncing