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
      "blur input#offline-widget-label"          : "getWidgetLabel"
      "blur .widget-label-form input[type=text]" : "getMessage"
      "click #offline-toggle"                    : "toggleSlider"
      "input .widget-label-form textarea"        : "updateWidgetMessage"
      "input input#offline-widget-label"         : "updateWidgetHeader"

    getMessage: (ev) ->
      @trigger "get:offline:form:event", ev

    getWidgetLabel: (ev) ->
      @trigger "get:offline:header", ev

    toggleSlider: (ev) ->
      unless $(ev.currentTarget).hasClass("toggle-off")
        @trigger "get:toggle:offline", false
        $(ev.currentTarget).addClass("toggle-off")
        $(ev.currentTarget).closest("form").submit()
      else
        $(ev.currentTarget).removeClass("toggle-off")
        @trigger "get:toggle:offline", true
        $(ev.currentTarget).closest("form").submit()

    updateWidgetMessage: (ev) ->
      $("#widget-pre-message").html($(ev.currentTarget).val())

    updateWidgetHeader: (ev) ->
      $(".widget-min-message span").text($(ev.target).val())

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
      "blur input#prechat-widget-label"          : "getWidgetLabel"
      "click #prechat-message-checkbox"          : "checkMessage"
      "click #prechat-email-checkbox"            : "checkEmail"
      "click #prechat-toggle"                    : "toggleSlider"
      "input .widget-label-form textarea"        : "updateWidgetMessage"
      "input input#prechat-widget-label"         : "updateWidgetLabel"

    getMessage: (ev) ->
      @trigger "get:prechat:form:event", ev

    getWidgetLabel: (ev) ->
      @trigger "get:prechat:header", ev

    checkMessage: (ev) ->
      unless $(ev.currentTarget).hasClass("checked")
        $(ev.currentTarget).addClass("checked")
        @trigger "get:prechat:message:check", true
        $(".widget-input-container > textarea").show()
      else
        $(ev.currentTarget).removeClass("checked")
        @trigger "get:prechat:message:check", false
        $(".widget-input-container > textarea").hide()

    checkEmail: (ev) ->
      unless $(ev.currentTarget).hasClass("checked")
        $(ev.currentTarget).addClass("checked")
        @trigger "get:prechat:email:check", true
        $(".widget-input-container > input.prechat-email").show()
      else
        $(ev.currentTarget).removeClass("checked")
        @trigger "get:prechat:email:check", false
        $(".widget-input-container > input.prechat-email").hide()

    toggleSlider: (ev) ->
      unless $(ev.currentTarget).hasClass("toggle-off")
        @trigger "get:toggle:prechat", false
        $(ev.currentTarget).addClass("toggle-off")
        $(ev.currentTarget).closest("form").submit()
      else
        $(ev.currentTarget).removeClass("toggle-off")
        @trigger "get:toggle:prechat", true
        $(ev.currentTarget).closest("form").submit()

    updateWidgetMessage: (ev) ->
      $("#widget-pre-message").html($(ev.currentTarget).val())

    updateWidgetLabel: (ev) ->
      $(".widget-min-message span").text($(ev.target).val())

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
      "input .widget-label-form textarea"        : "updateWidgetMessage"

    getMessage: (ev) ->
      @trigger "get:postchat:form:event", ev

    toggleSlider: (ev) ->
      unless $(ev.currentTarget).hasClass("toggle-off")
        @trigger "get:toggle:postchat", false
        $(ev.currentTarget).addClass("toggle-off")
        $(ev.currentTarget).closest("form").submit()
      else
        $(ev.currentTarget).removeClass("toggle-off")
        @trigger "get:toggle:postchat", true
        $(ev.currentTarget).closest("form").submit()

    updateWidgetMessage: (ev) ->
      $("#widget-pre-message").html($(ev.currentTarget).val())

