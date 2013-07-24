@Offerchat.module "SettingsApp.ChatForms", (ChatForms, App, Backbone, Marionette, $, _) ->
  class ChatForms.Controller extends App.Controllers.Base

    initialize: (options) ->
      { @currentSite, region, section } = options
      @currentUser     = App.request "set:current:user", App.request "get:current:user:json"
      @currentSite.url = Routes.update_settings_website_path(@currentSite.get('id'))

      @layout   = @getLayout()
      @settings = @currentSite.get('settings')

      @listenTo @layout, "show", =>
        @getSection section
        $(@layout.el).find("a[data-section='#{section}']").addClass("active")

        @listenTo @layout, "navigate:sub:forms", (section) =>
          section = (if section is 'offline' then '' else "/#{section}")
          App.navigate "settings/chat-forms/#{@currentSite.get("id")}#{section}", trigger: true

      @listenTo @currentSite, "updated", (site) =>
        @showNotification("Your changes have been saved!")

      @listenTo @layout, "hide:notification", =>
        $("#setting-notification").fadeOut()

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

        @listenTo showForms, "get:prechat:form:event", @setPreChatData
        @listenTo showForms, "get:prechat:message:check", (checked) =>
          @settings.pre_chat.message_required = checked
          @currentUser.set settings: @settings
        @listenTo showForms, "get:toggle:prechat", (enabled) =>
          @settings.pre_chat.enabled = enabled
          @currentUser.set settings: @settings
      else
        showForms = @getPostChatFormView()

        @listenTo showForms, "get:postchat:form:event", @setPostChatData
        @listenTo showForms, "get:toggle:postchat", (enabled) =>
          @settings.post_chat.enabled = enabled
          @currentUser.set settings: @settings

      formView = App.request "form:wrapper", showForms
      @layout.chatFormsRegion.show formView

      $(".widget-preview-sample > div > div").addClass('widget-gradient') if @settings.style.gradient
      $("#offline-toggle").addClass("toggle-off") unless @settings.offline.enabled
      $("#prechat-toggle").addClass("toggle-off") unless @settings.pre_chat.enabled
      $("#postchat-toggle").addClass("toggle-off") unless @settings.post_chat.enabled

      if !@settings.pre_chat.message_required and section is 'prechat'
        $(".widget-input-container > textarea").hide()
        $("#prechat-message-checkbox").removeClass("checked")

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

    setPreChatData: (ev) ->
      if $(ev.currentTarget).data('name') is 'description'
        @settings.pre_chat.description = $(ev.currentTarget).val()
      @currentUser.set settings: @settings

    setPostChatData: (ev) ->
      if $(ev.currentTarget).data('name') is 'description'
        @settings.post_chat.description = $(ev.currentTarget).val()
      else if $(ev.currentTarget).data('name') is 'email'
        @settings.post_chat.email = $(ev.currentTarget).val()

      @currentUser.set settings: @settings

