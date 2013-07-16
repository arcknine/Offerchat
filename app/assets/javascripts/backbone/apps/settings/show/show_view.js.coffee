@Offerchat.module "SettingsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "settings/show/layout"
    tagName:  "span"

    regions:
      sitesRegion:    "#settings-websites"
      settingsRegion: "#settings-main-region"

    events:
      "click .nav-sidebar-block > li > a" : "navigateSettings"

    navigateSettings: (e) ->
      @trigger "navigate:settings", $(e.currentTarget).data("section")

  class Show.Style extends App.Views.ItemView
    template:  "settings/show/style"
    className: "column-content-container"
    events:
      "click #controlColorContent a" : "changeColor"

    changeColor: (e) ->
      @trigger "style:color:clicked", e

    form:
      buttons:
        primary: "Save Changes"
        cancel: false

  class Show.Site extends App.Views.ItemView
    template: "settings/show/site"

  class Show.Sites extends App.Views.CompositeView
    template:  "settings/show/sites"
    className: "block large"
    itemView:  Show.Site
    itemViewContainer: "ul"

    events:
      "click div#sites-dropdown-button" : "showSitesList"

    showSitesList: (e) ->
      if $(e.currentTarget).find(".btn-selector").hasClass("open")
        $(e.currentTarget).find(".btn-selector").removeClass("open")
        $(e.currentTarget).find(".btn-action-selector.site-selector").removeClass("active")
      else
        $(e.currentTarget).find(".btn-selector").addClass("open")
        $(e.currentTarget).find(".btn-action-selector.site-selector").addClass("active")

    serializeData: ->
      currentSite: @options.currentSite.toJSON()
