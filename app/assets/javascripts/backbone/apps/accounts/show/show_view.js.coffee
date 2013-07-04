@Offerchat.module "AccountsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Layout extends App.Views.Layout
    template: "accounts/show/layout"
    
    regions:
      accountSidebarRegion:        "#accounts-sidebar-region"
      accountRegion:               "#accounts-main-region"
      
  class Show.Navs extends App.Views.ItemView
    template: "accounts/show/navs"
    
  class Show.Profile extends App.Views.ItemView
    template: "accounts/show/profile"