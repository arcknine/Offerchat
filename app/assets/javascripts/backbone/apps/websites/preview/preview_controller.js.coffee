@Offerchat.module "WebsitesApp.Preview", (Preview, App, Backbone, Marionette, $, _) ->

  class Preview.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      # try
      website = App.request "set:session:new:website"

      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @iframeRegion website
        @settingsRegion website
        # @getMainRegion(profile, options.section)

      App.previewRegion.show @layout
      # catch e
      #   App.navigate Routes.new_website_path(), trigger: true

    iframeRegion: (website) ->
      iframeView = @getIframeView website
      @layout.iframeRegion.show iframeView

    settingsRegion: (website) ->
      settingsView = @getSettingsView website
      formSettings = App.request "form:wrapper", settingsView
      @layout.settingsRegion.show formSettings

    getLayoutView: ->
      new Preview.Layout

    getIframeView: (website) ->
      new Preview.Iframe
        model: website

    getSettingsView: (website) ->
      new Preview.Settings
        model: website
