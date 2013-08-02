@Offerchat.module "AccountsApp.Password", (Password, App, Backbone, Marionette, $, _) ->

  class Password.Layout extends App.Views.Layout
    template: "accounts/password/layout"
    tagName: "span"

    regions:
      accountSidebarRegion:                       "#accounts-sidebar-region"
      accountRegion:                              "#accounts-main-region"

  class Password.Navs extends App.Views.ItemView
    template: "accounts/password/sidebar"
    triggers:
      "click a" :                                 "nav:clicked"
      "click a.profile" :                         "nav:accounts:clicked"
      "click a.password" :                        "nav:password:clicked"
      #"click a.notifications" :                   "nav:notifications:clicked"
      #"click a.invoices" :                        "nav:invoices:clicked"

  class Password.View extends App.Views.ItemView
    template: "accounts/password/password"
    events:
      "click .block-message a.close" :  "closeNotification"
    closeNotification: (e) ->
      $(e.currentTarget).parent("div").fadeOut()