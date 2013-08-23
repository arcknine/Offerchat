@Offerchat.module "ChatsApp.Agent", (Agent, App, Backbone, Marionette, $, _) ->

  class Agent.Controller extends App.Controllers.Base
    interval:  null
    composing: null

    initialize: (options ={}) ->
      { @token }   = options
      @connection = App.xmpp.connection
      @agents     = App.request "get:online:agents"
      @agent      = @agents.findWhere token: @token
      @agent      = App.request "online:agent:entity" if typeof @agent is "undefined"
      @messages   = App.request "get:agent:chats:messages"
      @height     = App.request "get:chat:window:height"
      @layout     = @getLayout()

      @listenTo @agents, "all", (type) =>
        unless type is "remove"
          agent = @agents.findWhere token: @token
          @agent.set agent.attributes

      @listenTo @messages, "add", (message) =>
        $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500);

      $(window).resize =>
        @height.set
          height: $(window).height()
          str_h:  ($(window).height() - 256) + "px"

      @listenTo @layout, "show", =>
        @agentInfo()
        @loadChatsView()

      @show @layout

    agentInfo: ->
      agentInfoView = @getAgentInfo()
      @layout.agentRegion.show agentInfoView

    loadChatsView: ->
      chatsView = @getChats()
      @listenTo chatsView, "agent:is:typing", @sendChat

      @listenTo chatsView, "childview:chat:transfer:accept", (msg) =>
        @respondTransfer msg.model, 'accepted'

        vtoken = msg.model.get('trn_vtoken')
        App.navigate "chats/visitor/#{vtoken}", trigger: true   # navigate to visitor chat

        App.request "set:no:active:agent:chat"
        App.request "set:no:active:visitor:chat"

        visitorList = App.request "get:chats:visitors"
        visitor = visitorList.findWhere token: vtoken
        visitor.set('active', 'active')

      @listenTo chatsView, "childview:chat:transfer:decline", (msg) =>
        @respondTransfer msg.model, 'declined'

      @layout.chatsRegion.show chatsView

    respondTransfer: (model, response) ->
      update_obj =
        trn_responded: true
        trn_status: response

      if response is 'accepted' then update_obj.trn_accepted = true

      model.set(update_obj)
      true

    sendChat: (ev) =>
      message = $(ev.currentTarget).val()
      clearInterval(@interval)

      if ev.keyCode is 13 and message isnt ""
        messages = App.request "messeges:entities"
        messages.add(@messages.where token: @token)

        @messages.add
          token:      @token
          sender:     "agent"
          name:       "You"
          message:    message
          time:       new Date()
          timesimple: moment().format('hh:mma')
          child:      (if messages.last() and messages.last().get("sender") is "agent" then true else false)
          childclass: (if messages.last() and messages.last().get("sender") is "agent" then "child" else "")

        $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500);
        $(ev.currentTarget).val("")
        @composing = null

        to  = "#{@agent.get("jid")}@#{gon.chat_info.server_name}"
        msg = $msg({to: to, type: "chat"}).c('body').t($.trim(message))

        @connectionSend msg, to

      else
        to        = "#{@agent.get("jid")}@#{gon.chat_info.server_name}"
        composing = $msg({type: 'chat', to: to}).c('composing', {xmlns: 'http://jabber.org/protocol/chatstates'})
        paused    = $msg({type: 'chat', to: to}).c('paused', {xmlns: 'http://jabber.org/protocol/chatstates'})
        inactive  = $msg({type: 'chat', to: to}).c('inactive', {xmlns: 'http://jabber.org/protocol/chatstates'})

        unless @composing?
          @connection.send composing
          @composing = true

        #send paused after 10s
        @interval = setInterval(=>
          @composing = null
          @connection.send paused
          clearInterval @interval
        , 10000)

    getLayout: ->
      new Agent.Layout

    getAgentInfo: ->
      new Agent.Info
        model: @agent

    getChats: ->
      new Agent.Chats
        collection: @messages
        model: @height
