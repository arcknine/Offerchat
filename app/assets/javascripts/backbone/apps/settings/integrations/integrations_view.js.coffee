@Offerchat.module "SettingsApp.Integrations", (Integrations, App, Backbone, Marionette, $, _) ->

  class Integrations.Layout extends App.Views.Layout
    template:  "settings/integrations/layout"
    className: "column-content-container"
    regions:
      integrationsRegion: "#integrations-region"

    triggers:
      "click .create-ticket" : "create:ticket"

    events:
      "click li.integrations" : "selectIntegration"

    selectIntegration: (e) ->
      target = $(e.currentTarget)
      selected = target.data("section")
      $("li.integrations").removeClass("active")
      target.addClass("active")

      @trigger "select:integration", selected

  class Integrations.Zendesk extends App.Views.ItemView
    template: "settings/integrations/zendesk"
    events:
      "blur input.large[type=text]" : "setIntegrationData"
      "click label.checkbox.inline" : "toggleCheckbox"

    triggers:
      "click button.save-zendesk"  : "save:zendesk:api"

    setIntegrationData: (e) ->
      name = $(e.currentTarget).attr("name")
      val  = $(e.currentTarget).val()

      @trigger "update:zendesk:data", { name: name, value: val }

    toggleCheckbox: (e) ->
      target = $(e.currentTarget)
      if target.hasClass("checked")
        checked = ""
        target.removeClass("checked")
      else
        checked = "checked"
        target.addClass("checked")

      @trigger "update:zendesk:offline:message", checked

  class Integrations.Desk extends App.Views.ItemView
    template: "settings/integrations/desk"
    events:
      "blur input.large[type=text]" : "setIntegrationData"
      "click label.checkbox.inline" : "toggleCheckbox"

    triggers:
      "click button.btn.action.save"  : "save:desk:api"

    setIntegrationData: (e) ->
      name = $(e.currentTarget).attr("name")
      val  = $(e.currentTarget).val()

      @trigger "update:desk:data", { name: name, value: val }

    toggleCheckbox: (e) ->
      console.log e
      target = $(e.currentTarget)
      if target.hasClass("checked")
        checked = ""
        target.removeClass("checked")
      else
        checked = "checked"
        target.addClass("checked")

      @trigger "update:desk:offline:message", checked

