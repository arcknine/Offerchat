@Offerchat.module "SidebarApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "sidebar/list/list_layout"

    regions:
      siteSelectorRegion:     "#site-selector-region"
      visitorsRegion:         "#visitors-region"
    
  class List.SiteSelector extends App.Views.ItemView
    template: "sidebar/list/site_selector"
    className: "site-selector-container"
    
    triggers:
      "click a.site-selector" : "siteselector:clicked"
    
  class List.Visitors extends App.Views.ItemView
    template: "sidebar/list/visitors"
    className: "chats-sidebar"