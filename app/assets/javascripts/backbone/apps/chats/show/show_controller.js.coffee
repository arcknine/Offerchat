@Offerchat.module "ChatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    visitorStorage: new Backbone.LocalStorage "visitor"

    interval:  null
    composing: null

    initialize: (options ={}) ->
      { @token }   = options
      @connection = App.xmpp.connection
      @layout     = @getLayout()

      allMessages = App.request "get:chats:messages"
      visitors    = App.request "get:chats:visitors"
      @visitor    = App.request "visitor:entity"
      @messages   = App.request "messeges:entities"

      unless allMessages.length is 0
        @messages.add(allMessages.where { jid: @token })

      unless visitors.length is 0
        @visitor.set visitors.findWhere({ jid: @token }).attributes

      @listenTo visitors, "add", (item) =>
        @visitor.set item.attributes if item.get("jid") is @token

      @listenTo allMessages, "add", (item) =>
        item.set { child: true, childclass: "child" } if @messages.last() and @messages.last().get("sender") is item.get("sender")
        @messages.add(item) if item.get("token") is @token

      @listenTo @layout, "show", =>
        @visitorInfoView @visitor
        @chatsView @messages

      @show @layout

    visitorInfoView: (visitor) ->
      visitorView = @getVisitorInfoView visitor

      @layout.visitorRegion.show visitorView

    chatsView: (messages) ->
      chatsView = @getChatsView messages

      @listenTo chatsView, "is:typing", @sendChat

      @layout.chatsRegion.show chatsView

    sendChat: (ev) =>
      message = $(ev.currentTarget).val()

      if ev.keyCode is 13 and message isnt ""
        @messages.add
          token:      @token
          sender:     "agent"
          jid:        "You"
          message:    message
          time:       new Date()
          timesimple: moment().format('hh:mma')
          child:      (if @messages.last() and @messages.last().get("sender") is "agent" then true else false)

        $(ev.currentTarget).val("")
      else
        composing = $msg({type: 'chat', to: @visitor.get("jid")}).c('composing', {xmlns: 'http://jabber.org/protocol/chatstates'})
        paused    = $msg({type: 'chat', to: @visitor.get("jid")}).c('paused', {xmlns: 'http://jabber.org/protocol/chatstates'})
        inactive  = $msg({type: 'chat', to: @visitor.get("jid")}).c('inactive', {xmlns: 'http://jabber.org/protocol/chatstates'})

        # console.log composing.toString()

    getLayout: ->
      new Show.Layout

    getVisitorInfoView: (visitor) ->
      new Show.VisitorInfo
        model: visitor

    getChatsView: (messages) ->
      new Show.ChatsList
        collection: messages

