@Offerchat.module "ReportsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    initialize: ->
      @manageSites = App.request "manage:sites:entities"
      @layout      = @getLayout()

      @listenTo @layout, "show", =>
        @initLayoutEvents()
        @initDatePicker "week"
        @showWebsites()

      @show @layout

    initLayoutEvents: ->
      @listenTo @layout, "quick:date:select", (type) =>
        $("#reports-date > .datepicker").remove()
        @initDatePicker type

    initDatePicker: (type) ->
      if type is "today"
        from = moment().format("YYYY-MM-DD")
        to   = moment().format("YYYY-MM-DD")
      else if type is "month"
        from = moment().startOf('month').format("YYYY-MM-DD")
        to   = moment().format("YYYY-MM-DD")
      else
        from = moment().startOf('week').format("YYYY-MM-DD")
        to   = moment().format("YYYY-MM-DD")

      current = moment().format("YYYY-MM-DD")

      $("#reports-date").DatePicker
        flat: true
        date: [from, to]
        current: current
        calendars: 3
        mode: "range"
        starts: 1
        onChange: (formated, dates) ->
          from = formated[0]
          to   = formated[1]

    showWebsites: ->
      websitesView = @getWebsites()
      @layout.websitesRegion.show websitesView

    getLayout: ->
      new Show.Layout

    getWebsites: ->
      new Show.Websites
        collection: @manageSites
