@Offerchat.module "MainApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Main extends App.Views.ItemView
    template: "main/show/main"