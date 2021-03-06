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

    serializeData: ->
      section: @options.section

    onShow: ->
      user = App.request "get:current:user:json"

      if ["PRO", "PROTRIAL", "AFFILIATE", "PROYEAR", "PRO6MONTHS", "OFFERFREE"].indexOf(user.plan_identifier) is -1
        $(@.$el).find("a[data-section='attention-grabbers']").parent("li").remove()
        $(@.$el).find("a[data-section='integrations']").parent("li").remove()


  class Show.Site extends App.Views.ItemView
    template: "settings/show/site"

    triggers:
      "click li > a" : "set:current:website"
      # "click li > a" : "setCurrentWebsite"

  class Show.Sites extends App.Views.CompositeView
    template:  "settings/show/sites"
    className: "block large"
    itemView:  Show.Site
    itemViewContainer: "ul"

    events:
      "click div#sites-dropdown-button" : "showSitesList"

    showSitesList: (e) ->
      @trigger "dropdown:sites", e

    serializeData: ->
      currentSite: @options.currentSite.toJSON()
