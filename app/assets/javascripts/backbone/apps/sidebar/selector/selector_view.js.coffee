@Offerchat.module "SidebarApp.Selector", (Selector, App, Backbone, Marionette, $, _) ->
  
  class Selector.Layout extends App.Views.Layout
    template: "sidebar/selector/layout"
    regions:
      selectedSiteRegion: "#siteSelector"
      optionsRegion:  "#options-elector"
    tagName: "span"
      
  class Selector.SiteSelector extends App.Views.CompositeView
    template: "sidebar/selector/site_selector"
    triggers:
      "click"    : "selector:clicked"

  class Selector.Website extends App.Views.ItemView
    template: "sidebar/selector/website"
    tagName: "li"
    triggers:
      "click a.new.unread"    : "selected:website:clicked"
    
  class Selector.Websites extends App.Views.CompositeView
    template: "sidebar/selector/websites"
    itemView: Selector.Website
    tagName: "ul"