@Offerchat.module "SettingsApp.Integrations", (Integrations, App, Backbone, Marionette, $, _) ->

  class Integrations.Controller extends App.Controllers.Base

    initialize: (options) ->
      profile      = App.request "get:current:profile"

      App.execute "when:fetched", profile, =>
        plan = profile.get("plan_identifier")

        if ["PRO", "PROTRIAL", "AFFILIATE"].indexOf(plan) isnt -1

          { @currentSite, region, section } = options
          @currentSite.url = Routes.update_settings_website_path(@currentSite.get('id'))

          @currentUser = App.request "get:current:profile"

          App.execute "when:fetched", @currentUser, =>
            @settings = @currentSite.get('settings')

            @layout = @getLayout()

            @listenTo @layout, "show", =>
              @getIntegrationView @currentSite.get("settings").integrations.integration

            @listenTo @layout, "select:integration", (integration) =>
              @getIntegrationView integration

            $(window).resize =>
              h = $(window).height() - 45
              $(".column-content-container").attr("style","height:#{h}px")

            @show @layout

        else
          App.navigate Routes.root_path(), trigger: true

    getIntegrationView: (integration) =>
      @settings = @currentSite.get "settings"

      if @settings.integrations.integration is integration
        data = { integrations: @settings.integrations.data }
      else
        data = { integrations: "" }

      @currentSite.set data
      @layout.$el.find(".integrations[data-section=#{integration}]").addClass("active")

      switch integration
        when "zendesk"
          @showZenDesk()
        when "desk"
          @showDesk()
        when "zoho"
          @showZoho()

    showZoho: ->
      zohoView = @getZohoView()
      formView = App.request "form:wrapper", zohoView
      data     = {}

      @listenTo zohoView, "update:zoho:data", (obj) =>
        data[obj.name] = obj.value

      @listenTo zohoView, "update:zoho:offline:message", (checked) =>
        data.offline_messages = checked

      @listenTo zohoView, "save:zoho:api", =>
        @settings.integrations.integration = "zoho"
        @settings.integrations.data = @serializeForm()

        @currentSite.save {},
          success: (data) =>
            @showNotification("Your changes have been saved.")

        return false

      @layout.integrationsRegion.show formView


    showZenDesk: ->
      zenDeskView = @getZendeskView()
      formView = App.request "form:wrapper", zenDeskView
      data     = {}

      @listenTo zenDeskView, "update:zendesk:data", (obj) =>
        data[obj.name] = obj.value

      @listenTo zenDeskView, "update:zendesk:offline:message", (checked) =>
        data.offline_messages = checked

      @listenTo zenDeskView, "save:zendesk:api", =>
        # console.log $("#form-content-region .form")
        @settings.integrations.integration = "zendesk"
        @settings.integrations.data = @serializeForm()

        @currentSite.save {},
          success: (data) =>
            @showNotification("Your changes have been saved.")

        return false

      @layout.integrationsRegion.show formView

    showDesk: ->
      deskView = @getDeskView()
      formView = App.request "form:wrapper", deskView
      data     = {}

      @listenTo deskView, "update:desk:data", (obj) =>
        data[obj.name] = obj.value

      @listenTo deskView, "update:desk:offline:message", (checked) =>
        data.offline_messages = checked

      @listenTo deskView, "save:desk:api", =>
        @settings.integrations.integration = "desk"
        @settings.integrations.data = @serializeForm()

        @currentSite.save {},
          success: (data) =>
            @showNotification("Your changes have been saved.")

        return false

      @layout.integrationsRegion.show formView

    serializeForm: ->
      form = $("#integrations-region form").serializeArray()
      data = { offline_messages: "" }
      $.each form, (key, value) ->
        data[value.name] = value.value
      if $("#integrations-region .checkbox.inline").hasClass("checked")
        data.offline_messages = "checked"

      data

    getLayout: ->
      new Integrations.Layout

    getDeskView: ->
      new Integrations.Desk
        model: @currentSite

    getZendeskView: ->
      new Integrations.Zendesk
        model: @currentSite

    getZohoView: ->
      new Integrations.Zoho
        model: @currentSite