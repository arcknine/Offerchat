@Offerchat.module "SettingsApp.Style", (Style, App, Backbone, Marionette, $, _) ->

  class Style.Layout extends App.Views.Layout
    template: "settings/style/layout"
    className: "column-content-container"
    events:
      "click #controlColorContent a" : "changeColor"
      "click .toggle-check"          : "toggleGradient"
      "click .toggle-footer"         : "toggleFooter"
      "blur #widget-label"           : "updateWidgetlabel"

    triggers:
      "click #setting-notification" : "hide:notification"
      "click .hide-footer"          : "style:hide:footer"
      "click .show-footer"          : "style:show:footer"
      "click a.upgrade-tip"         : "redirect:upgrade"

    changeColor: (e) ->
      @trigger "style:color:clicked", e

    toggleGradient: (e) ->
      @trigger "style:gradient:checked", e

    updateWidgetlabel: (e) ->
      @trigger "label:value:update", e

    toggleFooter: (e) ->
      console.log e

    serializeData: ->
      user: @options.user.toJSON()
      website: @options.model.toJSON()
      classname: @options.classname
      checked: @options.checked
      paid: @options.paid
