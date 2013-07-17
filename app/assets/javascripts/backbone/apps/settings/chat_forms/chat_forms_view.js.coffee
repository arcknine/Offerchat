@Offerchat.module "SettingsApp.ChatForms", (ChatForms, App, Backbone, Marionette, $, _) ->

  class ChatForms.Layout extends App.Views.Layout
    template:  "settings/chat_forms/layout"
    className: "column-content-container"
    regions:
      chatFormsRegion: "#chat-forms-region"

  class ChatForms.Offline extends App.Views.ItemView
    template:  "settings/chat_forms/offline"
    className: "block large"

    serializeData: ->
      user: @options.currentUser.toJSON()
      site: @options.model.toJSON()
