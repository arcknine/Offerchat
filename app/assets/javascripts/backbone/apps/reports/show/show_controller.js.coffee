@Offerchat.module "ReportsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    initialize: ->
      @manageSites = App.request "manage:sites:entities"
      @agents      = App.request "agents:entities"
      @curWebsite  = App.request "reports:current:website"
      @curAgent    = App.request "reports:current:agent"
      @curDate     = App.request "reports:current:date"
      @asgnAgents  = App.request "reports:assigned:agents"
      currentUser  = App.request "get:current:user:json"
      @ratings     = App.request "reports:get:ratings"
      @stats       = App.request "reports:get:stat"
      @layout      = @getLayout()

      App.execute "when:fetched", @agents, =>
        @asgnAgents.set @agents.models
        @currentUser = @agents.findWhere id: currentUser.id

      App.execute "when:fetched", @manageSites, =>
        @all_sites_ids = @manageSites.pluck("id")
        @manageSites.add { name: "All Websites", all: true }

        ratings = App.request "reports:get:ratings", @all_sites_ids, @getCurrrentAgentIds(), @getCurrentDate()
        @ratingPercentage ratings

        stats = App.request "reports:get:stats", @all_sites_ids, @getCurrrentAgentIds(), @getCurrentDate()
        @setStats stats

      @listenTo @layout, "show", =>
        @showWebsites()
        @showAgents()
        @showRatings()
        @showStats()

        @initMorrisGrap()
        @initLayoutEvents()
        @initDatePicker "week"

      @show @layout

    initLayoutEvents: ->
      @listenTo @layout, "quick:date:select", (type) =>
        $("#reports-date > .datepicker").remove()
        @initDatePicker type

      @listenTo @layout, "apply:selected:date", =>
        type   = @curDate.get("type")
        from   = moment(@from).format("MMM D, YYYY")
        to     = moment(@to).format("MMM D, YYYY")
        arType = { today: "Today", week: "This week", month: "This month",  custom: "#{from}  -  #{to}"}
        $(".calendar-picker-btn > span").text(arType[type])

        # if @from == @to
        #   @from = "#{@from} 00:00:00"
        #   @to   = "#{@to} 23:59:59"

        @curDate.set from: @from, to: @to
        ratings = App.request "reports:get:ratings", @all_sites_ids, @getCurrrentAgentIds(), @getCurrentDate()
        @ratingPercentage(ratings)

        stats = App.request "reports:get:stats", @all_sites_ids, @getCurrrentAgentIds(), @getCurrentDate()
        @setStats stats

    initMorrisGrap: ->
      data = [
        period: moment().format("YYYY-MM-DD")
        active: 0
        proactive: 0
        missed: 0
      ]

      @morrisGraph = Morris.Line
        element: "reports-graph"
        data: data
        xkey: "period"
        ykeys: ["active", "proactive", "missed"]
        labels: ["Active", "Proactive", "Missed"]
        lineColors: ["#3cb2e9", "#4ec192", "#f06767"]
        lineWidth: 2
        pointSize: 4
        smooth: true

    initDatePicker: (type) ->
      if type is "month"
        @from = moment().startOf('month').format("YYYY-MM-DD")
        @to   = moment().format("YYYY-MM-DD")
      else if type is "week"
        @from = moment().startOf('week').format("YYYY-MM-DD")
        @to   = moment().format("YYYY-MM-DD")
      else
        @from = moment().format("YYYY-MM-DD")
        @to   = moment().format("YYYY-MM-DD")

      @curDate.set type: type
      current = moment().format("YYYY-MM-DD")

      $("#reports-date").DatePicker
        flat: true
        date: [@from, @to]
        current: current
        calendars: 3
        mode: "range"
        starts: 1
        onChange: (formated, dates) =>
          @from = formated[0]
          @to   = formated[1]
          @curDate.set type: "custom"

    showWebsites: ->
      websitesView = @getWebsites()

      @listenTo websitesView, "childview:select:current:website", (site) =>
        $("#websites-region .btn-selector").removeClass("open")
        $("#websites-region .btn-action-selector").removeClass("active")
        @curWebsite.set site.model.attributes
        @curWebsite.set all: false unless site.model.get("name") is "All Websites"

        ratings = App.request "reports:get:ratings", @getCurrentSiteIds(), @getCurrrentAgentIds(), @getCurrentDate()
        @ratingPercentage ratings

        stats = App.request "reports:get:stats", @all_sites_ids, @getCurrrentAgentIds(), @getCurrentDate()
        @setStats stats

        @filterAgents site.model

      @layout.websitesRegion.show websitesView

    showAgents: ->
      agentsView = @getAgents()

      @listenTo agentsView, "toggle:all:agents", =>
        @curAgent.set all: true
        ratings = App.request "reports:get:ratings", @getCurrentSiteIds(), @getCurrrentAgentIds(), @getCurrentDate()
        @ratingPercentage ratings

        stats = App.request "reports:get:stats", @all_sites_ids, @getCurrrentAgentIds(), @getCurrentDate()
        @setStats stats

      @listenTo agentsView, "childview:toggle:selected:agent", (agent) =>
        @curAgent.set all: false
        @curAgent.set agent.model.attributes

        ratings = App.request "reports:get:ratings", @getCurrentSiteIds(), @getCurrrentAgentIds(), @getCurrentDate()
        @ratingPercentage ratings

        stats = App.request "reports:get:stats", @all_sites_ids, @getCurrrentAgentIds(), @getCurrentDate()
        @setStats stats

      @layout.agentsRegion.show agentsView

    showRatings: ->
      ratingsView = @getRatings()
      @layout.ratingsRegion.show ratingsView

    showStats: ->
      statsView = @getStats()
      @layout.statsRegion.show statsView

    filterAgents: (model) ->
      if model.get("name") is "All Websites"
        @asgnAgents.set @agents.models
      else
        agents = []
        $.each @agents.models, (key, agent) =>
          websites = agent.get("websites")
          $.each websites, (k, website) =>
            agents.push agent if website.id is model.get("id") and website.role isnt 0

        @asgnAgents.set agents

    getCurrentSiteIds: ->
      if @curWebsite.get("all") is true
        id = @all_sites_ids
      else
        id = [@curWebsite.get("id")]

      id

    getCurrrentAgentIds: ->
      if @curAgent.get("all") is true
        id = ""
      else
        id = [@curAgent.get("id")]

      id

    getCurrentDate: ->
      from: @curDate.get("from")
      to:   @curDate.get("to")

    ratingPercentage: (model) ->
      App.execute "when:fetched", model, =>
        up     = model.get("up") || 0
        down   = model.get("down") || 0
        total  = up + down
        up_p   = (up / total) * 100
        down_p = (down / total) * 100

        @ratings.set
          up: up
          down: down
          up_percent: Math.round(up_p)
          down_percent: Math.round(down_p)

    setStats: (collection) ->
      App.execute "when:fetched", collection, =>
        data = []
        total = { missed: 0, active: 0, proactive: 0 }

        $.each collection.models, (key, value) =>
          total =
            active: value.get("active") + total.active
            missed: value.get("missed") + total.missed
            proactive: value.get("proactive") + total.proactive

          data.push
            period: value.get("period")
            active: value.get("active")
            proactive: value.get("proactive")
            missed: value.get("missed")

        data = [
          period: moment().format("YYYY-MM-DD")
          active: 0
          proactive: 0
          missed: 0
        ] if data.length is 0

        @stats.set
          active: @addCommaSeparator(total.active)
          missed: @addCommaSeparator(total.missed)
          proactive: @addCommaSeparator(total.proactive)

        @morrisGraph.setData data

    addCommaSeparator: (input) ->
      output = input
      if parseFloat(input)
        input = new String(input)
        parts = input.split(".")
        parts[0] = parts[0].split("").reverse().join("").replace(/(\d{3})(?!$)/g, "$1,").split("").reverse().join("")
        output = parts.join(".")

      output

    getLayout: ->
      new Show.Layout

    getWebsites: ->
      new Show.Websites
        collection: @manageSites
        model: @curWebsite

    getAgents: ->
      new Show.Agents
        collection: @asgnAgents

    getRatings: ->
      new Show.Ratings
        model: @ratings

    getStats: ->
      new Show.Stats
        model: @stats
