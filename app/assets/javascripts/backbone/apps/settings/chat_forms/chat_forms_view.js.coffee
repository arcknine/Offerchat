@Offerchat.module "SettingsApp.ChatForms", (ChatForms, App, Backbone, Marionette, $, _) ->

  class ChatForms.Layout extends App.Views.Layout
    template:  "settings/chat_forms/layout"
    className: "column-content-container"
    regions:
      chatFormsRegion: "#chat-forms-region"

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

    events:
      "blur .widget-label-form textarea"         : "getOfflineMessage"
      "blur .widget-label-form input[type=text]" : "getOfflineMessage"
      "click #offline-toggle"                    : "toggleSlider"

    getOfflineMessage: (ev) ->
      @trigger "get:offline:form:event", ev

    toggleSlider: (ev) ->
      unless $(ev.currentTarget).hasClass("toggle-off")
        @trigger "get:toggle:offline", false
        $(ev.currentTarget).addClass("toggle-off")
      else
        $(ev.currentTarget).removeClass("toggle-off")
        @trigger "get:toggle:offline", true

  class ChatForms.PreChat extends App.Views.ItemView
    template:  "settings/chat_forms/prechat"
    className: "block large"

    serializeData: ->
      user: @options.currentUser.toJSON()
      site: @options.model.toJSON()

  class ChatForms.PostChat extends App.Views.ItemView
    template:  "settings/chat_forms/postchat"
    className: "block large"

    serializeData: ->
      user: @options.currentUser.toJSON()
      site: @options.model.toJSON()


