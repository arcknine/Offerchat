@Offerchat.module "SettingsApp.Language", (Language, App, Backbone, Marionette, $, _) ->

  class Language.Controller extends App.Controllers.Base
    initialize: (options) ->
      layout = @getLayoutView(options.currentSite)

      @currentUser = App.request "set:current:user", App.request "get:current:user:json"
      options.currentSite.url = Routes.update_settings_website_path(options.currentSite.get("id"))
      settings = options.currentSite.get('settings')

      @listenTo layout, "language:value:changed", (e) =>
        @updateWidgetLabel()

      @listenTo layout, "language:value:update", (e) =>
        settings.online.agent_label = $("#widget-label").val()
        options.currentSite.set settings: settings

      @listenTo options.currentSite, "updated", (site) =>
        @showNotification("Your changes have been saved!")

      @listenTo layout, "hide:notification", =>
        $("#setting-notification").fadeOut()

      formView = App.request "form:wrapper", layout
      layout.url = Routes.websites_path()
      @show formView

      @initWidget(options.currentSite)

    getLayoutView: (website) ->
      new Language.Layout
        model: website


    updateWidgetLabel: ->
      $("#widget-label-count").text(33 - $("#widget-label").val().length)
      $(".widget-welcome-msg").text($("#widget-label").val())

    initWidget: (website) ->
      # Display name
      $(".widget-agent-name").text(@currentUser.attributes.display_name)

      # Labels
      $(".widget-welcome-msg").text(website.attributes.settings.online.agent_label)
      $("#widget-label").val(website.attributes.settings.online.agent_label)

      # Label limit
      $("#widget-label-count").text(33 - website.attributes.settings.online.agent_label.length)

      # Widget style
      $("#widget-header").removeClass()
      $("#widget-header").addClass("widget-box widget-theme theme-#{website.attributes.settings.style.theme}")

      if website.attributes.settings.style.gradient
        $("#widget-header").children(":first").addClass("widget-gradient")