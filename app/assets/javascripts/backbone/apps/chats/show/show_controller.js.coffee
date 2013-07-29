@Offerchat.module "ChatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    connection: App.xmpp.connection
    visitorsStorage: new Backbone.LocalStorage "visitors-storage"

    initialize: (options ={}) ->
      { token } = options
      @layout   = @getLayout()
      @messages = App.request "get:chat:messages"
      @visitors = App.request "get:chat:visitors"
      @visitors = @visitors.add @visitorsStorage.all() if @visitors.length is 0
      visitor   = @visitors.findWhere { jid: token }

      @listenTo @layout, "show", =>
        @connection.addHandler @on_private_message, null, "message", "chat"
        @visitorInfoView visitor
        @chatsView()

      @show @layout

    visitorInfoView: (visitor) ->
      visitorView = @getVisitorInfoView visitor

      @layout.visitorRegion.show visitorView

    chatsView: ->
      chatsView   = @getChatsView()

      @layout.chatsRegion.show chatsView

    getLayout: ->
      new Show.Layout

    getVisitorInfoView: (visitor) ->
      new Show.VisitorInfo
        model: visitor

    getChatsView: ->
      new Show.ChatsList

