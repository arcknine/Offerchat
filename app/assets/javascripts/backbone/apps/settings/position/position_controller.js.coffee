@Offerchat.module "SettingsApp.Position", (Position, App, Backbone, Marionette, $, _) ->
  class Position.Controller extends App.Controllers.Base

    initialize: (options) ->
      { @currentSite, region } = options
      @currentSite.url = Routes.update_settings_website_path(@currentSite.get('id'))

      @layout  = @getLayoutView()
      formView = App.request "form:wrapper", @layout
      settings = @currentSite.get('settings')

      @listenTo @layout, "settings:position", (position) =>
        settings.style.position = position
        @currentSite.set settings: settings

      @listenTo @currentSite, "updated", (site) =>
        @showNotification("Your changes have been saved!")

      @listenTo @layout, "hide:notification", =>
        $("#setting-notification").fadeOut()

      @show formView

      @setPosition settings.style.position

    getLayoutView: ->
      new Position.View
        model: @currentSite

    setPosition: (position) ->
      @layout.$el.find(".widget-position-selector > a[data-position=#{position}]").addClass("active")
