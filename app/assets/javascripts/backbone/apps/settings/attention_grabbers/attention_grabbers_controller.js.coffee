@Offerchat.module "SettingsApp.AttentionGrabbers", (AttentionGrabbers, App, Backbone, Marionette, $, _) ->

  class AttentionGrabbers.Controller extends App.Controllers.Base

    initialize: (options) ->
      { @currentSite, region, section } = options
      @currentUser     = App.request "get:current:profile"
      @currentSite.url = Routes.update_settings_website_path(@currentSite.get('id'))

      App.execute "when:fetched", @currentUser, =>
        @layout   = @getLayout()

        @show @layout

    getLayout: ->
      new AttentionGrabbers.Layout
        model: @currentSite