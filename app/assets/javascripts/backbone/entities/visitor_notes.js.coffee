@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.VisitorNote extends App.Entities.Model
    urlRoot: "/visitor_notes"

  class Entities.VisitorNotes extends App.Entities.Collection
    model: Entities.VisitorNote

  API =
    newVisitorNote: ->
      new Entities.VisitorNote

    getVisitorNotes: (visitor) ->
      notes = new Entities.VisitorNotes
      notes.url = Routes.notes_visitor_path visitor
      notes.fetch
        reset: true
      notes

  App.reqres.setHandler "new:visitor_note", ->
    API.newVisitorNote()

  App.reqres.setHandler "get:visitor_notes", (visitor) ->
    API.getVisitorNotes visitor