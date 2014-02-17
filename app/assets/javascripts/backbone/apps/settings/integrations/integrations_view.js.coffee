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
    modelEvents:
      "all"   : "render"

    triggers:
      "click button.save-zendesk"  : "save:zendesk:api"

    serializeData: ->
      settings = @options.model.get("settings")
      zendesk: settings.zendesk

  class Integrations.Desk extends App.Views.ItemView
    template: "settings/integrations/desk"
    events:
      "blur input.large[type=text]" : "setIntegrationData"

    setIntegrationData: (e) ->
      name = $(e.currentTarget).attr("name")
      val  = $(e.currentTarget).val()

      @trigger "update:integration:data", { name: name, value: val }
