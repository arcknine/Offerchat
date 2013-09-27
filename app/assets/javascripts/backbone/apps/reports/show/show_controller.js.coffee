@Offerchat.module "ReportsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    initialize: ->
      @manageSites = App.request "manage:sites:entities"
      @agents      = App.request "agents:entities"
      @curWebsite  = App.request "reports:current:website"
      @asgnAgents  = App.request "reports:assigned:agents"
      currentUser  = App.request "get:current:user:json"

      @layout      = @getLayout()

      App.execute "when:fetched", @manageSites, =>
        @manageSites.add { name: "All Websites", all: true }

      App.execute "when:fetched", @agents, =>
        @asgnAgents.set @agents.models
        @currentUser = @agents.findWhere id: currentUser.id

      @listenTo @layout, "show", =>
        @showWebsites()
        @showAgents()

        @initLayoutEvents()
        @initMorrisGrap()
        @initDatePicker "week"

      @show @layout

    initLayoutEvents: ->
      @listenTo @layout, "quick:date:select", (type) =>
        $("#reports-date > .datepicker").remove()
        @initDatePicker type

    initMorrisGrap: ->
      data = [
          period: "2013-01-01"
          active: 0
          proactive: 0
          missed: 0
        ,
          period: "2013-01-02"
          active: 53
          proactive: 12
          missed: 4
        ,
          period: "2013-01-03"
          active: 78
          proactive: 32
          missed: 2
      ]

      Morris.Line
        element: "reports-graph"
        data: data
        xkey: "period"
        ykeys: ["active", "proactive", "missed"]
        labels: ["Active", "Proactive", "Missed"]
        lineColors: ["#3cb2e9", "#4ec192", "#f06767"]
        lineWidth: 2
        pointSize: 4
        smooth: false

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

      @listenTo websitesView, "childview:select:current:website", (site) =>
        $("#websites-region .btn-selector").removeClass("open")
        $("#websites-region .btn-action-selector").removeClass("active")
        @curWebsite.set site.model.attributes
        @curWebsite.set all: false unless site.model.get("name") is "All Websites"

        @filterAgents site.model

      @layout.websitesRegion.show websitesView

    showAgents: ->
      agentsView = @getAgents()

      @listenTo agentsView, "toggle:all:agents", =>
        console.log "all agent"

      @listenTo agentsView, "childview:toggle:selected:agent", (agent) =>
        console.log agent

      @layout.agentsRegion.show agentsView

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

    getLayout: ->
      new Show.Layout

    getWebsites: ->
      new Show.Websites
        collection: @manageSites
        model: @curWebsite

    getAgents: ->
      new Show.Agents
        collection: @asgnAgents
