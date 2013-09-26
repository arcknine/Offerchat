@Offerchat.module "ReportsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "reports/show/layout"
    className: "reports-wrapper"

    regions:
      websitesRegion: "#websites-region"
      agentsRegion:   "#agents-region"
      reportsRegion:  "#reports-region"

    events:
      "click a.calendar-picker-btn"        : "toggleDatePicker"
      "click div.date-control a.btn.small" : "quickDateSelect"

    toggleDatePicker: (e) ->
      $("#websites-region .btn-selector").removeClass("open") if $("#websites-region .btn-selector").hasClass("open")
      $("#websites-region .btn-action-selector").removeClass("active")

      wrapper = $(e.currentTarget).next()
      if wrapper.hasClass("hide") is true
        wrapper.removeClass("hide")
        $(e.currentTarget).addClass("active")
      else
        wrapper.addClass("hide")
        $(e.currentTarget).removeClass("active")

    quickDateSelect: (e) ->
      $("div.date-control a.btn.small").removeClass "active"
      $(e.target).addClass "active"
      @trigger "quick:date:select", $(e.target).data("type")

  class Show.Website extends App.Views.ItemView
    template: "reports/show/website"
    tagName:  "li"

  class Show.Websites extends App.Views.CompositeView
    template:  "reports/show/websites"
    itemView:  Show.Website
    itemViewContainer: "ul"
    collectionEvents:
      "change" : "render"

    events:
      "click div.btn-action-selector" : "showWebsites"

    showWebsites: (e) ->
      $(".history-date-wrapper").addClass("hide") unless $(".history-date-wrapper").hasClass("hide")
      $(".calendar-picker-wrapper > a.calendar-picker-btn").removeClass("active")

      parent = $(e.currentTarget).parent()
      if parent.hasClass("open")
        parent.removeClass("open")
        $(e.currentTarget).removeClass("active")
      else
        parent.addClass("open")
        $(e.currentTarget).addClass("active")

  class Show.Reports extends App.Views.ItemView
    template: "reports/show/show"
    className: "block large"
    events:
      "click a.agent-inline-block": "toggleAgent"
    toggleAgent: (e) ->
      $(e.currentTarget).addClass "selected"