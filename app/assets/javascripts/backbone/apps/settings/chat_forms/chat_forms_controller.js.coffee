@Offerchat.module "SettingsApp.ChatForms", (ChatForms, App, Backbone, Marionette, $, _) ->
  class ChatForms.Controller extends App.Controllers.Base

    initialize: (options) ->
      { @currentSite, region, section } = options
      @currentUser = App.request "set:current:user", App.request "get:current:user:json"

      # @currentSite.url = "websites/save_settings/#{@currentSite.get('id')}"
      @layout  = @getLayout()
      settings = @currentSite.get('settings')

      @listenTo @layout, "show", =>
        @getSection section
        $(@layout.el).find("a[data-section='#{section}']").addClass("active")

      @show @layout

    getLayout: ->
      new ChatForms.Layout
        model: @currentSite

    getSection: (section) ->
      if section is 'offline'
        showForms = @getOfflineFormView()
        console.log @currentSite
      else if section is 'prechat'
        console.log section
      else
        console.log section

      @layout.chatFormsRegion.show showForms

    getOfflineFormView: ->
      new ChatForms.Offline
        model: @currentSite
        currentUser: @currentUser
