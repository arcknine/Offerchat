@Offerchat.module "SettingsApp.Integrations", (Integrations, App, Backbone, Marionette, $, _) ->

  class Integrations.Controller extends App.Controllers.Base

    initialize: (options) ->
      profile = App.request "get:current:profile"

      App.execute "when:fetched", profile, =>
        plan = profile.get("plan_identifier")

        if ["PRO", "PROTRIAL", "AFFILIATE"].indexOf(plan) isnt -1

          { @currentSite, region, section } = options

          @currentUser = App.request "get:current:profile"

          App.execute "when:fetched", @currentUser, =>
            @settings = @currentSite.get('settings')

            @layout = @getLayout()

            @listenTo @layout, "show", =>
              @getIntegrationView "zendesk"

            @listenTo @layout, "select:integration", (integration) =>
              @getIntegrationView integration

            $(window).resize =>
              h = $(window).height() - 45
              $(".main-content-view").attr("style","height:#{h}px")

            @show @layout

        else
          App.navigate Routes.root_path(), trigger: true

    getLayout: ->
      new Integrations.Layout
        model: @currentSite

    getZendeskView: ->
      new Integrations.Zendesk
        model: @currentSite

    zendeskIntegration: ->
      integrationView = @getZendeskView()

      @listenTo integrationView, "save:zendesk:api", =>
        z_company = $("#zendesk-company").val()
        z_username = $("#zendesk-username").val()
        z_token = $("#zendesk-token").val()

        if (z_company isnt "" and z_username isnt "" and z_token isnt "") or (z_company is "" and z_username is "" and z_token is "")
          @settings.zendesk.company = z_company
          @settings.zendesk.username = z_username
          @settings.zendesk.token = z_token

          @currentSite.url = Routes.update_settings_website_path(@currentSite.get('id'))
          @currentSite.set settings: @settings
          @currentSite.save {},
            success: (data) =>
              @showNotification("Your changes have been saved.")
        else
          @showNotification("All zendesk fields are required", "warning")

      integrationView

    getIntegrationView: (integration) =>
      if integration is "zendesk"
        integrationView = @zendeskIntegration()


      @layout.integrationsRegion.show integrationView