@Offerchat.module "ReportsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "reports/show/layout"
    className: "reports-wrapper"

    regions:
      websitesRegion: "#websites-region"
      agentsRegion:   "#agents-region"
      ratingsRegion:  "#ratings-region"
      statsRegion:    "#stats-region"
      stats2Region:   "#stats-2-region"

    events:
      "click a.calendar-picker-btn"              : "toggleDatePicker"
      "click div.date-control a.btn.small"       : "quickDateSelect"
      "click div.date-control button.btn.action" : "applyDate"
      "click div.date-control > a"               : "cancelDateSelect"

    toggleDatePicker: (e) ->
      unless gon.current_user.plan_identifier is "TRIAL"
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

    applyDate: ->
      $(".history-date-wrapper").addClass("hide")
      @trigger "apply:selected:date", true

    cancelDateSelect: ->
      $(".history-date-wrapper").addClass("hide")

  class Show.Website extends App.Views.ItemView
    template: "reports/show/website"
    tagName:  "li"
    triggers:
      "click" : "select:current:website"

  class Show.Websites extends App.Views.CompositeView
    template:  "reports/show/websites"
    itemView:  Show.Website
    itemViewContainer: "ul"
    modelEvents:
      "change" : "render"

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

  class Show.Agent extends App.Views.ItemView
    template:  "reports/show/agent"
    tagName:   "a"
    className: "btn-toggle bordered"

    events:
      "click" : "toggleAgent"

    toggleAgent: (e) ->
      $(".toggle-list a").removeClass("active")
      $(e.currentTarget).addClass("active")

      @trigger "toggle:selected:agent", this

  class Show.Agents extends App.Views.CompositeView
    template:  "reports/show/agents"
    itemView:  Show.Agent
    className: "toggle-list"
    itemViewContainer: "div#agents-wrapper"
    collectionEvents:
      "change" : "render"

    events:
      "click a.btn-toggle-all.all-agents" : "toggleAllAgents"

    toggleAllAgents: (e) ->
      $(".toggle-list a").removeClass("active")
      $(e.currentTarget).addClass("active")

      @trigger "toggle:all:agents", "all"

  class Show.Ratings extends App.Views.ItemView
    template: "reports/show/ratings"
    modelEvents:
      "change" : "render"

  class Show.Stats extends App.Views.ItemView
    template: "reports/show/stats"
    modelEvents:
      "change" : "render"

  class Show.Stats2 extends App.Views.ItemView
    template: "reports/show/stats2"
    tagName:  "span"
    modelEvents:
      "change" : "render"
