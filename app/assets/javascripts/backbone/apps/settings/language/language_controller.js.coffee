@Offerchat.module "SettingsApp.Language", (Language, App, Backbone, Marionette, $, _) ->

  class Language.Controller extends App.Controllers.Base
    initialize: (options) ->
      { @currentSite } = options
      console.log @currentSite
      @currentUser = App.request "get:current:profile"
      @layout      = @getLayoutView()
      @settings    = @currentSite.get("settings")
      @counter     = 33 - (@settings.online.agent_label.length)

      @currentSite.url = Routes.update_settings_website_path(@currentSite.get('id'))

      App.execute "when:fetched", @currentUser , =>
        @setlabels()

      @listenTo @currentSite, "updated", (site) =>
        @showNotification("Your changes have been saved!")

      @listenTo @layout, "show", =>
        @setLanguages()
        @setlabels()

      @show @layout

    setlabels: ->
      labelsView = @getLabelView()

      @listenTo labelsView, "label:value:changed", (e) =>
        $(labelsView.el).find(".widget-welcome-msg").text $(e.target).val()
        @counter = 33 - ($(e.target).val().length)
        $(labelsView.el).find("#widget-label-count").text(@counter)

      @listenTo labelsView, "label:value:update", (e) =>
        label = $(e.target).val()
        @settings.online.agent_label = label
        @currentSite.set settings: @settings

      formView = App.request "form:wrapper", labelsView
      console.log formView.el
      $(formView.el).submit ->
        # console.log "test"
        return false

      @layout.labelRegion.show formView

    setLanguages: ->
      languageView = @getLanguageView()
      # @layout.languageRegion.show languageView

    getLabelView: ->
      new Language.Labels
        model: @currentSite
        user:  @currentUser
        counter: @counter

    getLanguageView: ->
      new Language.Langs

    getLayoutView: ->
      new Language.Layout