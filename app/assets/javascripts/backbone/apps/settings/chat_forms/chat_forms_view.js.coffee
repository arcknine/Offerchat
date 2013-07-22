@Offerchat.module "SettingsApp.ChatForms", (ChatForms, App, Backbone, Marionette, $, _) ->

  class ChatForms.Layout extends App.Views.Layout
    template:  "settings/chat_forms/layout"
    className: "column-content-container"
    regions:
      chatFormsRegion: "#chat-forms-region"

    triggers:
      "click #setting-notification" : "hide:notification"

    events:
      "click ul.section-sub-menu a" : "navigateSubForms"

    navigateSubForms: (ev) ->
      @trigger "navigate:sub:forms", $(ev.currentTarget).data("section")

  class ChatForms.Offline extends App.Views.ItemView
    template:  "settings/chat_forms/offline"
    className: "block large"

    serializeData: ->
      user: @options.currentUser.toJSON()
      site: @options.model.toJSON()

    triggers:
      "click button.widget-button" : ""

    events:
      "blur .widget-label-form textarea"         : "getMessage"
      "blur .widget-label-form input[type=text]" : "getMessage"
      "click #offline-toggle"                    : "toggleSlider"
      "keyup .widget-label-form textarea"        : "updateWidgetMessage"

    getMessage: (ev) ->
      @trigger "get:offline:form:event", ev

    toggleSlider: (ev) ->
      unless $(ev.currentTarget).hasClass("toggle-off")
        @trigger "get:toggle:offline", false
        $(ev.currentTarget).addClass("toggle-off")
      else
        $(ev.currentTarget).removeClass("toggle-off")
        @trigger "get:toggle:offline", true

    updateWidgetMessage: (ev) ->
      $(".widget-pre-message").html($(ev.currentTarget).val())

  class ChatForms.PreChat extends App.Views.ItemView
    template:  "settings/chat_forms/prechat"
    className: "block large"

    serializeData: ->
      user: @options.currentUser.toJSON()
      site: @options.model.toJSON()

    triggers:
      "click button.widget-button" : ""

    events:
      "blur .widget-label-form textarea"         : "getMessage"
      "click #prechat-message-checkbox"          : "checkMessage"
      "click #prechat-toggle"                    : "toggleSlider"
      "keyup .widget-label-form textarea"        : "updateWidgetMessage"

    getMessage: (ev) ->
      @trigger "get:prechat:form:event", ev

    checkMessage: (ev) ->
      unless $(ev.currentTarget).hasClass("checked")
        $(ev.currentTarget).addClass("checked")
        @trigger "get:prechat:message:check", true
        $(".widget-input-container > textarea").show()
      else
        $(ev.currentTarget).removeClass("checked")
        @trigger "get:prechat:message:check", false
        $(".widget-input-container > textarea").hide()

    toggleSlider: (ev) ->
      unless $(ev.currentTarget).hasClass("toggle-off")
        @trigger "get:toggle:prechat", false
        $(ev.currentTarget).addClass("toggle-off")
      else
        $(ev.currentTarget).removeClass("toggle-off")
        @trigger "get:toggle:prechat", true

    updateWidgetMessage: (ev) ->
      $(".widget-pre-message").html($(ev.currentTarget).val())

  class ChatForms.PostChat extends App.Views.ItemView
    template:  "settings/chat_forms/postchat"
    className: "block large"

    serializeData: ->
      user: @options.currentUser.toJSON()
      site: @options.model.toJSON()

    triggers:
      "click button.widget-button" : ""

    events:
      "blur .widget-label-form textarea"         : "getMessage"
      "blur .widget-label-form input[type=text]" : "getMessage"
      "click #postchat-toggle"                   : "toggleSlider"
      "keyup .widget-label-form textarea"        : "updateWidgetMessage"

    getMessage: (ev) ->
      @trigger "get:postchat:form:event", ev

    toggleSlider: (ev) ->
      unless $(ev.currentTarget).hasClass("toggle-off")
        @trigger "get:toggle:postchat", false
        $(ev.currentTarget).addClass("toggle-off")
      else
        $(ev.currentTarget).removeClass("toggle-off")
        @trigger "get:toggle:postchat", true

    updateWidgetMessage: (ev) ->
      $(".widget-pre-message").html($(ev.currentTarget).val())

