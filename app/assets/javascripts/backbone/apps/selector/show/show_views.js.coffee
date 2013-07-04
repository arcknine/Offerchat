@Offerchat.module "SiteselectorApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.View extends App.Views.CompositeView
    template: "selector/show/selector"