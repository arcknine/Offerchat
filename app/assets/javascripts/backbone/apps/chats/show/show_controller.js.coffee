@Offerchat.module "ChatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options ={}) ->
      @layout = @getLayout()

      @listenTo @layout, "show", =>
        @visitorInfoView()
        @chatsView()

      @show @layout

    visitorInfoView: ->
      visitorView = @getVisitorInfoView()

      @layout.visitorRegion.show visitorView

    chatsView: ->
      chatsView   = @getChatsView()

      @layout.chatsRegion.show chatsView

    getLayout: ->
      new Show.Layout

    getVisitorInfoView: ->
      new Show.VisitorInfo

    getChatsView: ->
      new Show.ChatsList

