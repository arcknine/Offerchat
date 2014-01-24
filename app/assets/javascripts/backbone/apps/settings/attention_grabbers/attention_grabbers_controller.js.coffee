@Offerchat.module "SettingsApp.AttentionGrabbers", (AttentionGrabbers, App, Backbone, Marionette, $, _) ->

  class AttentionGrabbers.Controller extends App.Controllers.Base

    initialize: (options) ->
      { @currentSite, region, section } = options
      @currentUser     = App.request "get:current:profile"
      @currentSite.url = Routes.update_settings_website_path(@currentSite.get('id'))

      App.execute "when:fetched", @currentUser, =>
        @settings = @currentSite.get('settings')

        @layout   = @getLayout()

        @listenTo @layout, "show", =>
          $("#attention-grabber-toggle").addClass("toggle-off") unless @settings.grabber.enabled

        @listenTo @layout, "save:attention:grabber", =>
          enabled = true
          if $("#attention-grabber-toggle").hasClass("toggle-off")
            enabled = false

          @settings.grabber.enabled = enabled
          @currentSite.set settings: @settings
          @currentSite.save {},
            success: (data) =>
              @showNotification("Your changes have been saved!")

        @show @layout



    getLayout: ->
      new AttentionGrabbers.Layout
        model: @currentSite