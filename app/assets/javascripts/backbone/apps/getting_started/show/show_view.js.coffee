@Offerchat.module "GettingStartedApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Main extends App.Views.ItemView
    template: "getting_started/show/main"
    className: "main-inner"
    triggers:
      "click .remove-msg" : "remove:message"