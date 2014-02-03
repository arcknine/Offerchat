@Offerchat.module "SettingsApp.Language", (Language, App, Backbone, Marionette, $, _) ->

  class Language.Layout extends App.Views.Layout
    template: "settings/language/layout"
    className: "column-content-container"

    triggers:
      "click .save-language"   :  "save:language"

    events:
      "click a.set-language"  :  "selectLanguage"

    selectLanguage: (e) ->
      $(".set-language").removeClass("selected")
      $(e.currentTarget).addClass("selected")