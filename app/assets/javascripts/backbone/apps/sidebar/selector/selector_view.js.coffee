@Offerchat.module "SidebarApp.Selector", (Selector, App, Backbone, Marionette, $, _) ->

  class Selector.Layout extends App.Views.Layout
    template: "sidebar/selector/layout"
    regions:
      # selectedSiteRegion: "#siteSelector"
      optionsRegion:  "#options-selector"
    className: "site-selector-container"

    modelEvents:
      "change": "render"

    triggers:
      "click a#selector-all-websites" : "selector:all:websites"
      "click a.new-website-link"      : "selector:new:website"
      "click a.site-selector"         : "selector:clicked"

  # class Selector.SiteSelector extends App.Views.CompositeView
  #   template: "sidebar/selector/site_selector"
  #   tagName: "span"
  #   modelEvents:
  #     "change": "render"

  #   triggers:
  #     "click"    : "selector:clicked"

  class Selector.Website extends App.Views.ItemView
    template: "sidebar/selector/website"
    tagName: "li"
    triggers:
      "click a" : "selected:website:clicked"

  class Selector.Websites extends App.Views.CompositeView
    template: "sidebar/selector/websites"
    itemView: Selector.Website
    tagName: "ul"

    collectionEvents:
      "change": "render"