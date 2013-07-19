@Offerchat.module "SidebarApp.Wizards", (Wizards, App, Backbone, Marionette, $, _) ->
  class Wizards.Preview extends App.Views.ItemView
    template: "sidebar/wizards/preview"