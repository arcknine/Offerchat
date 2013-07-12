@Offerchat.module "WebsitesApp.Preview", (Preview, App, Backbone, Marionette, $, _) ->

  class Preview.Layout extends App.Views.Layout
    template: "websites/preview/layout"
    regions:
      iframeRegion:   "#website-iframe-region"
      settingsRegion: "#website-settings-region"
      widgetRegion:   "#website-chat-widget-region"

  class Preview.Iframe extends App.Views.ItemView
    template: "websites/preview/iframe"

  class Preview.Settings extends App.Views.ItemView
    template:  "websites/preview/settings"
    className: "control-modal"

  class Preview.Widget extends App.Views.ItemView
    template: "websites/preview/widget"
    className: "widget-box widget-theme theme-darkslategrey"

  class Preview.Color extends App.Views.ItemView
    template: "websites/preview/color"
