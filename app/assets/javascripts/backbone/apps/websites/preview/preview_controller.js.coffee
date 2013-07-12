@Offerchat.module "WebsitesApp.Preview", (Preview, App, Backbone, Marionette, $, _) ->

  class Preview.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      # try
      website = App.request "set:session:new:website"

      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @iframeRegion website
        @settingsRegion website
        @widgetRegion website
        # @getMainRegion(profile, options.section)

      App.previewRegion.show @layout
      # catch e
      #   App.navigate Routes.new_website_path(), trigger: true

    iframeRegion: (website) ->
      iframeView = @getIframeView website
      @layout.iframeRegion.show iframeView

    widgetRegion: (website) ->
      widgetView = @getWidgetView website
      @layout.widgetRegion.show widgetView

    settingsRegion: (website) ->

      settingsView = @getSettingsView website
      # settingsView = @getColorView website
      formSettings = App.request "form:wrapper", settingsView

      @listenTo website, "updated", (model) =>


      @layout.settingsRegion.show formSettings

    getColorView: ->
      new Preview.Color

    getLayoutView: ->
      new Preview.Layout

    getIframeView: (website) ->
      new Preview.Iframe
        model: website

    getSettingsView: (website) ->
      new Preview.Settings
        model: website

    getWidgetView: ->
      new Preview.Widget
