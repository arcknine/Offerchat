@Offerchat.module "AgentsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayoutView()
      agents = App.request "agents:entities"

      @layout.on "show", =>
        # @showSeats agents # temporary seats set
        @showAgents agents

      App.mainRegion.show @layout

    showSeats: (seats) ->
      seatsView = @getSeatsView seats
      @layout.seatsRegion.show seatsView

    showAgents: (agents) ->
      agentsView = @getAgentsView agents
      @layout.agentsRegion.show agentsView

    getLayoutView: ->
      new List.Layout

    getAgentsView: (agents) ->
      new List.Agents
        collection: agents

    getSeatsView: (seats) ->
      new List.Seats seats