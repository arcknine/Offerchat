@Offerchat.module "AccountsApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Layout extends App.Views.Layout
    template: "accounts/show/layout"
    
    regions:
      accountSidebarRegion:        "#accounts-sidebar-region"
      accountRegion:               "#accounts-main-region"
      
  class Show.Navs extends App.Views.ItemView
    template: "accounts/show/navs"
    triggers:
      "click a" :                  "nav:clicked"
      "click a.profile" :          "nav:accounts:clicked"
      "click a.password" :         "nav:password:clicked"
    
  class Show.Profile extends App.Views.ItemView
    template: "accounts/show/profile"
  
  class Show.Password extends App.Views.ItemView
    template: "accounts/show/password"