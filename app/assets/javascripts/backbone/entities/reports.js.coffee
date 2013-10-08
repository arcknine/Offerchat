@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.AssignedAgent extends App.Entities.Model

  class Entities.AssignedAgents extends App.Entities.Collection
    model: Entities.AssignedAgent

  class Entities.CurrentWebsite extends App.Entities.Model
    defaults:
      all:  true
      name: "All Websites"

  class Entities.CurrentAgent extends App.Entities.Model
    defaults:
      all: true
      name: "All agents"

  class Entities.CurrentDate extends App.Entities.Model
    defaults:
      from: moment().startOf('week').format("YYYY-MM-DD")
      to: moment().format("YYYY-MM-DD")

  class Entities.Rating extends App.Entities.Model
    defaults:
      up : 0
      down: 0
      up_percent: 0
      down_percent: 0

  class Entities.Stat extends App.Entities.Model
    defaults:
      active: 0
      proactive: 0
      missed: 0

  class Entities.Stats extends App.Entities.Collection
    model: Entities.Stat

  API =
    assignedAgents: ->
      new Entities.AssignedAgents

    currentWebsite: ->
      new Entities.CurrentWebsite

    currentAgent: ->
      new Entities.CurrentAgent

    currentDate: ->
      new Entities.CurrentDate

    getRatings: (wid, uid, date) ->
      ratings = new Entities.Rating

      if wid or uid or date
        ratings.url = Routes.ratings_reports_path()

        data = {}
        data.website_id = wid if wid
        data.user_id = uid if uid

        if date
          data.from = date.from
          data.to   = date.to

        App.request "show:preloader"
        ratings.fetch
          type:  "post"
          reset: true
          data:  data
          success: ->
            App.request "hide:preloader"

      ratings

    getStats: (wid, uid, date) ->
      stats = new Entities.Stats

      if wid or uid or date
        stats.url = Routes.stats_reports_path()

        data = {}
        data.website_id = wid if wid
        data.user_id = uid if uid

        if date
          data.from = date.from
          data.to   = date.to

        App.request "show:preloader"
        stats.fetch
          type:  "post"
          reset: true
          data:  data
          success: ->
            App.request "hide:preloader"

      stats

    getStat: ->
      new Entities.Stat

  App.reqres.setHandler "reports:assigned:agents", ->
    API.assignedAgents()

  App.reqres.setHandler "reports:current:website", ->
    API.currentWebsite()

  App.reqres.setHandler "reports:current:agent", ->
    API.currentAgent()

  App.reqres.setHandler "reports:current:date", ->
    API.currentDate()

  App.reqres.setHandler "reports:get:ratings", (website_id = "", user_id = "", date = "") ->
    API.getRatings website_id, user_id, date

  App.reqres.setHandler "reports:get:stats", (website_id = "", user_id = "", date = "") ->
    API.getStats website_id, user_id, date

  App.reqres.setHandler "reports:get:stat", ->
    API.getStat()

