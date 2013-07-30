@Offerchat.module "ChatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    visitorStorage: new Backbone.LocalStorage "visitor"

    initialize: (options ={}) ->
      { token }   = options
      @connection = App.xmpp.connection
      @layout     = @getLayout()

      allMessages = App.request "get:chats:messages"
      visitors    = App.request "get:chats:visitors"
      visitor     = App.request "visitor:entity"
      messages    = App.request "messeges:entities"

      unless allMessages.length is 0
        messages.add(allMessages.where { jid: token })

      unless visitors.length is 0
        visitor.set visitors.findWhere({ jid: token }).attributes

      @listenTo visitors, "add", (item) =>
        visitor.set item.attributes if item.get("jid") is token

      @listenTo allMessages, "add", (item) =>
        item.set { timesimple: moment(item.get("time")).format('hh:mma') }
        item.set { child: true, childclass: "child" } if messages.last() and messages.last().get("jid") is token
        messages.add(item) if item.get("jid") is token

      @listenTo @layout, "show", =>
        @visitorInfoView visitor
        @chatsView messages

      @show @layout

    visitorInfoView: (visitor) ->
      visitorView = @getVisitorInfoView visitor

      @layout.visitorRegion.show visitorView

    chatsView: (messages) ->
      chatsView = @getChatsView messages

      @layout.chatsRegion.show chatsView

    getLayout: ->
      new Show.Layout

    getVisitorInfoView: (visitor) ->
      new Show.VisitorInfo
        model: visitor

    getChatsView: (messages) ->
      new Show.ChatsList
        collection: messages

