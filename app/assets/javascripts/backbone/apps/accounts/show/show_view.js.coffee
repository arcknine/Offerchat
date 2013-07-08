@Offerchat.module "AccountsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "accounts/show/layout"

    regions:
      accountSidebarRegion: "#accounts-sidebar-region"
      accountRegion:        "#accounts-main-region"

  class Show.Navs extends App.Views.ItemView
    template: "accounts/show/navs"
    triggers:
      "click a"               : "nav:clicked"
      "click a.profile"       : "nav:accounts:clicked"
      "click a.password"      : "nav:password:clicked"
      "click a.notifications" : "nav:notifications:clicked"
      "click a.invoices"      : "nav:invoices:clicked"

  class Show.Profile extends App.Views.ItemView
    template: "accounts/show/profile"

    triggers:
      "click .column-footer-actions button" : "account:profile:form:submit"

  class Show.Password extends App.Views.ItemView
    template: "accounts/show/password"

    form:
      buttons:
        primary: "Save Changes"
        cancel: false

  class Show.Notifications extends App.Views.ItemView
    template:  "accounts/show/notifications"
    className: "column-content-container"

    triggers:
      "click label.checkbox"  : "notification:checkbox:clicked"


  class Show.Invoice extends App.Views.ItemView
    template:   "accounts/show/invoice"
    tagName:    "div"
    className:  "table-row group"

  class Show.Invoices extends App.Views.CompositeView
    template:           "accounts/show/invoices"
    itemViewContainer:  "div"
    className:          "table-history-viewer-content"
    itemView:            Show.Invoice