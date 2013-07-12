@Offerchat.module "Components.Preview", (Preview, App, Backbone, Marionette, $, _) ->

  class Preview.PreviewWrapper extends App.Views.Layout
    template: "preview/preview"