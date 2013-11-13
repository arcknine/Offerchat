@Offerchat.module "ResponsesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "responses/list/layout"
    # regions:
    #   seatsRegion:  "#seats-region"
    #   agentsRegion: "#agents-region"
