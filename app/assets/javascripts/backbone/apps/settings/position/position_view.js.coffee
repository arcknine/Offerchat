@Offerchat.module "SettingsApp.Position", (Position, App, Backbone, Marionette, $, _) ->

  class Position.View extends App.Views.ItemView
    template: "settings/position/position"
    className: "column-content-container"

    events:
      "click .widget-position-selector > a" : "selectPosition"

    triggers:
      "click #setting-notification" : "hide:notification"

    selectPosition: (ev) ->
      position = $(ev.currentTarget).data("position")

      $(this.$el).find("input[type=hidden]").val(position)
      $(this.$el).find(".widget-position-selector > a").removeClass("active")
      $(ev.currentTarget).addClass("active")

      @trigger "settings:position", position