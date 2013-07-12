@Offerchat.module "SettingsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "settings/show/layout"

    regions:
      settingsSidebarRegion:                       "#settings-sidebar-region"
      settingsRegion:                              "#settings-main-region"

  class Show.Nav extends App.Views.ItemView
    template: "settings/show/nav"
    triggers:
      "click a.language" : "nav:language:clicked"
      "click a.style-and-color"    : "nav:style:clicked"

  class Show.Style extends App.Views.ItemView
    template: "settings/show/style"
    events:
      "click #controlColorContent a" : "changeColor"
    changeColor: (e) ->
      $("#controlColorContent a").removeClass("active")
      $(e.currentTarget).addClass("active")
    form:
      buttons:
        primary: "Save Changes"
        cancel: false