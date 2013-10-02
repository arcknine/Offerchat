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
      from: moment().format("YYYY-MM-DD 00:00:00")
      to: moment().format("YYYY-MM-DD 23:59:59")

  class Entities.Rating extends App.Entities.Model
    defaults:
      up : 0
      down: 0
      up_percent: 0
      down_percent: 0

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

