@Offerchat.module "MainApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      @currentUser = App.request "get:current:user:json"
      planIdent    = @currentUser.plan_identifier
      @layout      = (if planIdent is null || planIdent is "" then @getMainView() else @showOwnerMain())

      # App.mainRegion.show mainView
      @show @layout

    showOwnerMain: ->
      layout = @getOwnerView()

      @listenTo layout, "show", =>
        @showStats()
        @showLastAgentLogin()

      layout

    showLastAgentLogin: ->
      @agents = App.request "agents:only:entities"
      @agents.comparator = "last_sign_in_at"
      view    = @getLastAgentLogin()

      App.execute "when:fetched", @agents, =>
        @agents.each (agent, key) =>
          unless agent.get("last_sign_in_at")
            agent.set "last_login", false
          else
            last_login = agent.get("last_sign_in_at")
            agent.set "last_login", moment(last_login).fromNow()

        @agents.sort()

      @layout.latAgentActive.show view

    showStats: ->
      @stats      = App.request "reports:get:stat"
      manageSites = App.request "manage:sites:entities"
      curDate     = App.request "reports:current:date"
      summary = @getChatSummary()

      App.execute "when:fetched", manageSites, =>
        all_sites_ids = manageSites.pluck("id")

        date = new Date()
        date.setDate(date.getDate() - 1)
        from = "#{date.getFullYear()}-#{date.getMonth() + 1}-#{date.getDate()}"

        current_date =
          from: from
          to:   curDate.get("to")

        stats = App.request "reports:get:stats", all_sites_ids, "", current_date

        App.execute "when:fetched", stats, =>
          total = { missed: 0, active: 0, proactive: 0, opportunities: 0 }

          $.each stats.models, (key, value) =>
            total =
              active: value.get("active") + total.active
              missed: value.get("missed") + total.missed
              proactive: value.get("proactive") + total.proactive
              opportunities: opportunities + total.opportunities

          @stats.set
            active: @addCommaSeparator(total.active)
            missed: @addCommaSeparator(total.missed)
            proactive: @addCommaSeparator(total.proactive)
            opportunities: @addCommaSeparator(total.opportunities)

      @layout.chatSummary.show summary

    addCommaSeparator: (input) ->
      output = input
      if parseFloat(input)
        input = new String(input)
        parts = input.split(".")
        parts[0] = parts[0].split("").reverse().join("").replace(/(\d{3})(?!$)/g, "$1,").split("").reverse().join("")
        output = parts.join(".")

      output

    getMainView: ->
      new Show.Main

    getOwnerView: ->
      new Show.OwnerMain

    getChatSummary: ->
      new Show.ChatSummary
        model: @stats

    getLastAgentLogin: ->
      new Show.Agents
        collection: @agents