@Offerchat.module "SettingsApp.Language", (Language, App, Backbone, Marionette, $, _) ->

  class Language.Controller extends App.Controllers.Base
    initialize: (options) ->
      { @currentSite } = options
      @currentUser = App.request "get:current:profile"
      @layout      = @getLayoutView()
      @settings    = @currentSite.get("settings")
      @counter     = 33 - (@settings.online.agent_label.length)

      @currentSite.url = Routes.update_settings_website_path(@currentSite.get('id'))

      @listenTo @layout, "save:language", =>
        lang = $("a.selected").find("img").attr("alt")
        @settings.style.language = lang

        @currentSite.set settings: @settings
        @currentSite.save {},
          success: (data) =>
            @showNotification("Your changes have been saved.")

      @listenTo @layout, "show", =>
        lang = @settings.style.language
        $("img[alt='#{lang}']").parent("a").addClass("selected")

      @show @layout

    getLayoutView: ->
      new Language.Layout
