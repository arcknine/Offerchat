@Offerchat.module "SidebarApp.Visitors", (Visitors, App, Backbone, Marionette, $, _) ->

  class Visitors.List extends App.Views.CompositeView
    template: "sidebar/visitors/visitors"