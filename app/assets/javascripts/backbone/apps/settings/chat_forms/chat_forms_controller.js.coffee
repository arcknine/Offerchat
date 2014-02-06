@Offerchat.module "SettingsApp.ChatForms", (ChatForms, App, Backbone, Marionette, $, _) ->
  class ChatForms.Controller extends App.Controllers.Base

    initialize: (options) ->
      { @currentSite, region, section } = options
      @currentUser     = App.request "get:current:profile"
      @currentSite.url = Routes.update_settings_website_path(@currentSite.get('id'))

      App.execute "when:fetched", @currentUser, =>
        @settings = @currentSite.get('settings')
        @current_language = Language[@settings.style.language]

        @layout   = @getLayout()

        @listenTo @layout, "show", =>
          @getSection section
          $(@layout.el).find("a[data-section='#{section}']").addClass("active")

          @listenTo @layout, "navigate:sub:forms", (section) =>
            section = (if section is 'prechat' then '' else "/#{section}")
            App.navigate "settings/chat-forms/#{@currentSite.get("id")}#{section}", trigger: true

          @text_counter "textarea[name=description]", ".text-limit-counter", 140

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

        @listenTo showForms, "get:offline:header", (ev) =>
          @settings.offline.header = $(ev.target).val()
          @currentUser.set settings: @settings

      else if section is 'prechat'
        showForms = @getPreChatFormView()

        @listenTo showForms, "get:prechat:form:event", @setPreChatData
        @listenTo showForms, "get:prechat:message:check", (checked) =>
          @settings.pre_chat.message_required = checked
          @currentUser.set settings: @settings

        @listenTo showForms, "get:prechat:email:check", (checked) =>
          @settings.pre_chat.email_required = checked
          @currentUser.set settings: @settings

        @listenTo showForms, "get:toggle:prechat", (enabled) =>
          @settings.pre_chat.enabled = enabled
          @currentUser.set settings: @settings

        @listenTo showForms, "get:prechat:header", (e) =>
          label = $(e.target).val()
          @settings.pre_chat.header = label
          @currentUser.set settings: @settings
          # $(".widget-min-message span").text(label)
          # console.log $(e.target).val()

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

      if !@settings.pre_chat.email_required and section is 'prechat'
        $(".widget-input-container > input.prechat-email").hide()
        $("#prechat-email-checkbox").removeClass("checked")

    getOfflineFormView: ->
      new ChatForms.Offline
        model: @currentSite
        currentUser: @currentUser
        language: @current_language

    getPreChatFormView: ->
      new ChatForms.PreChat
        model: @currentSite
        currentUser: @currentUser
        language: @current_language

    getPostChatFormView: ->
      new ChatForms.PostChat
        model: @currentSite
        currentUser: @currentUser

    setOfflineData: (ev) ->
      if $(ev.currentTarget).data('name') is 'description'
        @settings.offline.description = $(ev.currentTarget).val()
      else if $(ev.currentTarget).data('name') is 'email'
        @settings.offline.email = $(ev.currentTarget).val()

      @currentSite.set settings: @settings

    setPreChatData: (ev) ->
      if $(ev.currentTarget).data('name') is 'description'
        @settings.pre_chat.description = $(ev.currentTarget).val()
      @currentSite.set settings: @settings

    setPostChatData: (ev) ->
      if $(ev.currentTarget).data('name') is 'description'
        @settings.post_chat.description = $(ev.currentTarget).val()
      else if $(ev.currentTarget).data('name') is 'email'
        @settings.post_chat.email = $(ev.currentTarget).val()

      @currentSite.set settings: @settings

    text_counter: (input, target, max) ->
      init_text = $(input).val()
      init_count = max - init_text.length
      $(target).text init_count + " characters left"
      $(input).bind 'input propertychange', ->
        text = $(input).val()
        count = max - text.length
        $(target).text count + " characters left"
        if count < 0
          $(@).parent().addClass "field-error"
        else
          $(@).parent().removeClass "field-error"
          $(@).parent().parent().removeClass "field-error"
          $(@).parent().parent().find("label span.inline-label-message").remove()

