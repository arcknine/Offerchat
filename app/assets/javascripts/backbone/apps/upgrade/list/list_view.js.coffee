@Offerchat.module "UpgradeApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "upgrade/list/layout"
    className: "column-content-container"
    # regions:
    #   seatsRegion:  "#seats-region"
    #   agentsRegion: "#agents-region"