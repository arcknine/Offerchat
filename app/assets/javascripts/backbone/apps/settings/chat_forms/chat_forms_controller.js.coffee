@Offerchat.module "SettingsApp.ChatForms", (ChatForms, App, Backbone, Marionette, $, _) ->
  class ChatForms.Controller extends App.Controllers.Base

    initialize: (options) ->
      { @currentSite, region, section } = options
      @currentUser = App.request "set:current:user", App.request "get:current:user:json"
      # @currentSite.url =
      # @currentSite.url = "websites/save_settings/#{@currentSite.get('id')}"
      @layout   = @getLayout()
      @settings = @currentSite.get('settings')
      console.log @currentSite

      @listenTo @layout, "show", =>
        @getSection section
        $(@layout.el).find("a[data-section='#{section}']").addClass("active")

        @listenTo @layout, "navigate:sub:forms", (section) =>
          section = (if section is 'offline' then '' else "/#{section}")
          App.navigate "settings/chat-forms/#{@currentSite.get("id")}#{section}", trigger: true

      @show @layout

    getLayout: ->
      new ChatForms.Layout
        model: @currentSite

    getSection: (section) ->
      if section is 'offline'
        showForms = @getOfflineFormView()
        @listenTo showForms, "get:offline:form:event", @setOfflineData
        @listenTo showForms, "get:toggle:offline", (enabled) =>
          @settings.offline.enabled = enabled
          @currentUser.set settings: @settings
      else if section is 'prechat'
        showForms = @getPreChatFormView()
      else
        showForms = @getPostChatFormView()

      formView = App.request "form:wrapper", showForms
      @layout.chatFormsRegion.show formView

      $("#offline-toggle").addClass("toggle-off") unless @settings.offline.enabled
      $("#prechat-toggle").addClass("toggle-off") unless @settings.pre_chat.enabled
      $("#postchat-toggle").addClass("toggle-off") unless @settings.post_chat.enabled

    getOfflineFormView: ->
      new ChatForms.Offline
        model: @currentSite
        currentUser: @currentUser

    getPreChatFormView: ->
      new ChatForms.PreChat
        model: @currentSite
        currentUser: @currentUser

    getPostChatFormView: ->
      new ChatForms.PostChat
        model: @currentSite
        currentUser: @currentUser

    setOfflineData: (ev) ->
      if $(ev.currentTarget).data('name') is 'description'
        @settings.offline.description = $(ev.currentTarget).val()
      else if $(ev.currentTarget).data('name') is 'email'
        @settings.offline.email = $(ev.currentTarget).val()

      @currentUser.set settings: @settings
